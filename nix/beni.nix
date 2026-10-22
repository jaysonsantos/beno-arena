{
  stdenvNoCC,
  zorg,
  src,
}:
stdenvNoCC.mkDerivation {
  pname = "beni";
  version = "0.0.0-ab70761";
  inherit src;
  nativeBuildInputs = [ zorg ];
  dontConfigure = true;
  dontFixup = true;
  buildPhase = ''
    runHook preBuild
    export ZORG_GLOBAL_CACHE_DIR="$PWD/.zorg-cache"
    zorg build -j2 --prefix "$out"
    runHook postBuild
  '';
  dontInstall = true;
  meta.mainProgram = "beni";
}
