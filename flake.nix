{
  description = "Beno Arena: a beni browser frontend and Zorg-built compiler";

  # Keep the compiler, Workers tools, and package set on one tested revision.
  inputs.nixpkgs.follows = "beni-src/nixpkgs";
  inputs.beni-src = {
    url = "github:canassa/beni/ab70761e3546db04a5daeffdc82a554e38d30f19";
  };

  outputs =
    {
      self,
      nixpkgs,
      beni-src,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      tools =
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          zorg = pkgs.callPackage ./nix/zorg.nix { };
          beni = pkgs.callPackage ./nix/beni.nix {
            inherit zorg;
            src = beni-src;
          };
        in
        {
          inherit pkgs zorg beni;
        };
    in
    {
      packages = forAllSystems (
        system:
        let
          inherit (tools system) pkgs zorg beni;
          frontend = pkgs.stdenvNoCC.mkDerivation {
            pname = "beno-arena-frontend";
            version = "0.0.0";
            src = pkgs.lib.fileset.toSource {
              root = ./.;
              fileset = pkgs.lib.fileset.unions [
                ./beni.json
                ./frontend
                ./game
                ./scripts/build-page.sh
              ];
            };
            nativeBuildInputs = [ beni ];
            dontConfigure = true;
            buildPhase = ''
              runHook preBuild
              export BENO_TOOLCHAIN=1
              export XDG_CACHE_HOME="$PWD/.scratch/cache"
              bash scripts/build-page.sh
              runHook postBuild
            '';
            installPhase = ''
              runHook preInstall
              mkdir -p "$out"
              cp -r build/page/. "$out/"
              runHook postInstall
            '';
          };
          worker = pkgs.stdenvNoCC.mkDerivation {
            pname = "beno-arena-worker";
            version = "0.0.0";
            src = pkgs.lib.fileset.toSource {
              root = ./.;
              fileset = pkgs.lib.fileset.unions [
                ./server
                ./game
                ./scripts/build-worker.sh
              ];
            };
            nativeBuildInputs = [ beni ];
            dontConfigure = true;
            buildPhase = ''
              runHook preBuild
              export BENO_TOOLCHAIN=1
              bash scripts/build-worker.sh
              runHook postBuild
            '';
            installPhase = ''
              runHook preInstall
              mkdir -p "$out"
              cp -r build/worker/. "$out/"
              runHook postInstall
            '';
          };
        in
        {
          inherit
            zorg
            beni
            frontend
            worker
            ;
          default = frontend;
        }
      );

      devShells = forAllSystems (
        system:
        let
          inherit (tools system) pkgs zorg beni;
        in
        rec {
          default = pkgs.mkShell {
            packages = [
              # Compile beni and run its generated modules.
              zorg
              beni
              pkgs.nodejs_24
              # Serve local assets and check repository files.
              pkgs.python3
              pkgs.jq
              pkgs.prek
              pkgs.nixfmt
              pkgs.taplo
              pkgs.shellcheck
              pkgs.typos
              pkgs.gitleaks
              pkgs.zizmor
              pkgs.editorconfig-checker
              pkgs.python3Packages.pre-commit-hooks
            ]
            ++ pkgs.lib.optionals pkgs.stdenv.isLinux [ pkgs.chromium ];
            shellHook = ''
              export BENO_TOOLCHAIN=1
              export BENI_SOURCE="${beni-src}"
              export TMPDIR="$PWD/.scratch/tmp"
              export PREK_HOME="$PWD/.scratch/prek"
              export ZORG_GLOBAL_CACHE_DIR="$PWD/.scratch/zorg"
              mkdir -p "$TMPDIR" "$PREK_HOME" "$ZORG_GLOBAL_CACHE_DIR"
            '';
          };
          # Reuse the exact Workers shell that this compiler revision supplies.
          workers = pkgs.mkShell {
            inputsFrom = [
              default
              beni-src.devShells.${system}.workers
            ];
          };
        }
      );

      checks = forAllSystems (system: {
        frontend = self.packages.${system}.frontend;
        worker = self.packages.${system}.worker;
      });
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
