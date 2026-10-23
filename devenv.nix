{ pkgs, inputs, ... }:
let
  # The workers shell contains the default shell through inputsFrom.
  shell = inputs.beno.devShells.${pkgs.stdenv.system}.workers;
in
{
  # Pull the prebuilt beni and Zorg derivations.
  # Push new builds when CACHIX_AUTH_TOKEN is set.
  cachix.pull = [ "jaysonsantos" ];
  cachix.push = "jaysonsantos";

  packages = shell.nativeBuildInputs ++ shell.buildInputs;
  enterShell = shell.shellHook;
}
