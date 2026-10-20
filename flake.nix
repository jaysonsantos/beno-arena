{
  description = "A small authoritative multiplayer snake game";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { nixpkgs, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
    in {
      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in { default = pkgs.mkShell {
          packages = with pkgs; [
            # Runtime for compiled beni programs.
            nodejs_24
            # Repository checks and release tools.
            prek nixfmt shellcheck typos taplo gitleaks git-cliff editorconfig-checker
          ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
            # Browser smoke tests on Linux.
            pkgs.chromium
          ];
          CHROMIUM_PATH = pkgs.lib.optionalString pkgs.stdenv.isLinux "${pkgs.chromium}/bin/chromium";
          shellHook = ''
            export TMPDIR="$PWD/.scratch"
            export PREK_HOME="$PWD/.scratch/prek"
            mkdir -p "$TMPDIR"
          '';
        }; });
    };
}
