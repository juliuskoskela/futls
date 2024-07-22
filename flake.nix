{
  description = "Futls: Some flake utilities...";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { ... }: {
    lib = import ./default.nix;
  };
}
