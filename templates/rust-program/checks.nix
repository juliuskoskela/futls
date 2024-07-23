{
  pkgs,
  futls,
  rustEnv,
}: let
  myAppCheck = futls.lib.mkCheck {
    inherit pkgs;
    inherit (rustEnv) buildInputs nativeBuildInputs;
    src = ./.;
  };
in {
  cargo-clippy = myAppCheck {
    name = "cargo-clippy";
    check = ''
      cargo clippy -- -D warnings
    '';
  };

  cargo-test = myAppCheck {
    name = "cargo-test";
    check = ''
      cargo test --all
    '';
  };

  nix-fmt = myAppCheck {
    name = "nix-fmt";
    check = ''
      ${pkgs.alejandra}/bin/alejandra -c .
    '';
  };
}
