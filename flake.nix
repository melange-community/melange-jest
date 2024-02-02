{
  description = "melange-jest Nix Flake";

  inputs.nix-filter.url = "github:numtide/nix-filter";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs = {
    url = "github:nix-ocaml/nix-overlays";
    inputs.flake-utils.follows = "flake-utils";
  };
  inputs.melange-src = {
    url = "github:melange-re/melange";
    inputs.nix-filter.follows = "nix-filter";
    inputs.flake-utils.follows = "flake-utils";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, nix-filter, melange-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}".appendOverlays [
          (self: super: {
            ocamlPackages = super.ocaml-ng.ocamlPackages_5_1;
          })
          melange-src.overlays.default
        ];
        inherit (pkgs) nodejs_latest lib stdenv darwin yarn cacert;

        melange-jest = with pkgs.ocamlPackages; buildDunePackage {
          pname = "melange-jest";
          version = "dev";

          src = ./.;
          nativeBuildInputs = with pkgs.ocamlPackages; [ melange ];
          propagatedBuildInputs = with pkgs.ocamlPackages; [ melange ];
          doCheck = true;
          nativeCheckInputs = [ reason nodejs_latest yarn cacert ];
          checkInputs = [ melange-webapi cacert ];
          checkPhase = ''
            dune build @all -p melange-jest --display=short
            yarn install --no-default-rc --frozen-lockfile --check-files --cache-folder .ycache && rm -rf .ycache
            ./node_modules/.bin/jest
          '';
        };

        mkShell = { buildInputs ? [ ] }: pkgs.mkShell {
          inputsFrom = [ melange-jest ];
          nativeBuildInputs = with pkgs; [
            yarn
            nodejs_latest
          ] ++ (with pkgs.ocamlPackages; [
            ocamlformat
            merlin
            reason
          ]);
          inherit buildInputs;
        };
      in
      rec {
        packages.default = melange-jest;
        devShells = {
          default = mkShell { };
          release = mkShell {
            buildInputs = with pkgs; [ cacert curl ocamlPackages.dune-release git ];
          };
        };
      });
}
