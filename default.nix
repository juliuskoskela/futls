let
  mkCheck = {
    name,
    pkgs,
    check,
    src ? null,
    buildInputs ? [],
    nativeBuildInputs ? [],
  }:
    pkgs.stdenv.mkDerivation {
      inherit name src buildInputs nativeBuildInputs;

      checkPhase = check;
      dontBuild = true;
      doCheck = true;
      installPhase = "mkdir -p $out";
    };

  forEachSystem = systems: f: let
    # Merge together the outputs for all systems.
    op = attrs: system: let
      ret = f system;
      op = attrs: key:
        attrs
        // {
          ${key} =
            (attrs.${key} or {})
            // {${system} = ret.${key};};
        };
    in
      builtins.foldl' op attrs (builtins.attrNames ret);
  in
    builtins.foldl' op {}
    (systems
      ++ # add the current system if --impure is used
      (
        if builtins ? currentSystem
        then
          if builtins.elem builtins.currentSystem systems
          then []
          else [builtins.currentSystem]
        else []
      ));
in {
  inherit mkCheck forEachSystem;
}
