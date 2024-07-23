{
  description = "A flake for a Rust project using cargo2nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    futls.url = "github:juliuskoskela/futls";
    cargo2nix = {
      url = "github:cargo2nix/cargo2nix/release-0.11.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    futls,
    cargo2nix,
  }: let
    # Define supported systems
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  in
    # Build the output set for each default system and map system sets into
    # attributes, resulting in paths expressed as:
    # nix build .#packages.<system>.<name>
    futls.lib.forEachSystem supportedSystems (
      system: let
        # Create nixpkgs that contains rustBuilder from cargo2nix overlay
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            cargo2nix.overlays.default
          ];
        };

        # Create the workspace & dependencies package set
        rustPkgs = pkgs.rustBuilder.makePackageSet {
          # Define the rust toolchain
          rustVersion = "1.79.0";
          rustChannel = "stable";
          rustProfile = "default";
          # If the project structure and dependencies change, Cargo.nix will
          # need to be updated. This can be done by entering a development
          # shell with `nix develop and running the `cargo2nix` command.
          packageFun = import ./Cargo.nix;
        };

        # The workspace defines a development shell with all of the dependencies
        # and environment settings necessary for a regular `cargo build`
        rustEnv = rustPkgs.workspaceShell {
          packages = [cargo2nix.packages."${system}".cargo2nix];
        };

        # Define the package for the workspace
        myPackage = (rustPkgs.workspace.my-app {}).bin;

        # Define the app for the workspace
        myApp = {
          type = "app";
          program = "${myPackage}/bin/my-app";
        };
      in {
        # Define development shells that can be entered from this workspace
        devShells = {
          # nix develop .#my-env
          my-env = rustEnv;
          # nix develop
          default = rustEnv;
        };

        # Define packages that can be built from this workspace
        packages = {
          # nix build .#my-app
          # nix build .#packages.<system>.my-app
          my-package = myPackage;
          # nix build
          default = myPackage;
        };

        # Define apps that can be run from this workspace
        apps = {
          # nix run github:owner/repo#my-app
          my-app = myApp;
          # nix run github:owner/repo
          default = myApp;
        };

        # Define additional checks to run under the command:
        # nix flake check
        checks = import ./checks.nix {inherit pkgs futls rustEnv;};

        # Define the formatter for this workspace used with the command:
        # nix fmt .
        formatter = pkgs.alejandra;
      }
    );
}
