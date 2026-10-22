{ stdenvNoCC, fetchurl }:
let
  releases = {
    x86_64-linux = {
      target = "x86_64-linux";
      sha256 = "43bc8ba478639b840dddd83268a1b6491cf272dffce4006a7614824c5ac1e5f9";
    };
    aarch64-linux = {
      target = "aarch64-linux";
      sha256 = "2691c737b95b81bcee719ed6b3fa8ec828336837401e7879ab4060d4689716de";
    };
    aarch64-darwin = {
      target = "aarch64-macos";
      sha256 = "fe2fc1d21322795d8e9633ec51540da2b5d78d39ba0a10a63e25f8ce173c2384";
    };
  };
  release = releases.${stdenvNoCC.hostPlatform.system};
in
stdenvNoCC.mkDerivation {
  pname = "zorg";
  version = "0.17.1+zorg.1";
  src = fetchurl {
    url = "https://github.com/canassa/zorg/releases/download/v0.17.1-zorg.1/zorg-${release.target}-0.17.1-zorg.1.tar.xz";
    inherit (release) sha256;
  };
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;
  installPhase = ''
    install -Dm755 zorg "$out/bin/zorg"
    mkdir -p "$out/lib/zorg"
    cp -r lib/. "$out/lib/zorg/"
  '';
}
