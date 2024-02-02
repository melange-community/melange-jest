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

        checkPhaseNodePackages = pkgs.buildNpmPackage {
          name = "melange-jest-deps";
          version = "0.0.0-dev";

          src = ./.;
          dontNpmBuild = true;
          npmDepsHash = "sha256-FJEGqD2SwkGur+dSWtMW1Jr3Rmh68nQGUtEoprkXSfo=";
          installPhase = ''
            runHook preInstall
            mkdir -p "$out"
            cp -r ./node_modules "$out/node_modules"
            runHook postInstall
          '';
        };

        melange-jest = with pkgs.ocamlPackages; buildDunePackage {
          pname = "melange-jest";
          version = "dev";

          src = ./.;
          nativeBuildInputs = with pkgs.ocamlPackages; [ melange ];
          propagatedBuildInputs = with pkgs.ocamlPackages; [ melange ];
          doCheck = true;
          nativeCheckInputs = [ reason nodejs_latest yarn cacert ];
          checkInputs = [ melange-webapi cacert checkPhaseNodePackages ];
          checkPhase = ''
            dune build @all -p melange-jest --display=short
            ln -sfn "${checkPhaseNodePackages}/node_modules" ./node_modules
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
