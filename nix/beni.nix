{
  stdenvNoCC,
  zorg,
  src,
}:
stdenvNoCC.mkDerivation {
  pname = "beni";
  version = "0.0.0-${src.shortRev}";
  inherit src;
  nativeBuildInputs = [ zorg ];
  dontConfigure = true;
  dontFixup = true;
  buildPhase = ''
    runHook preBuild
    export ZORG_GLOBAL_CACHE_DIR="$PWD/.zorg-cache"
    # Cached binaries must run on other machines of this architecture.
    zorg build -j2 -Dcpu=baseline --prefix "$out"
    runHook postBuild
  '';
  dontInstall = true;
  meta.mainProgram = "beni";
}
