{
  description = "melange-jest Nix Flake";

  inputs.nixpkgs.url = "github:nix-ocaml/nix-overlays";

  outputs = { self, nixpkgs }:
    let
      forAllSystems = f: nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system:
        let
          pkgs = nixpkgs.legacyPackages.${system}.extend (self: super: {
            ocamlPackages = super.ocaml-ng.ocamlPackages_5_2;
          });
        in
        f pkgs);
    in
    {
      packages = forAllSystems (pkgs:
        let
          inherit (pkgs) nodejs_latest lib stdenv darwin yarn cacert;

          checkPhaseNodePackages = pkgs.buildNpmPackage {
            name = "melange-jest-deps";
            version = "0.0.0-dev";
            src =
              let fs = pkgs.lib.fileset; in
              fs.toSource {
                root = ./.;
                fileset = fs.unions [
                  ./dune-project
                  ./dune
                  ./melange-jest.opam
                  ./melange-jest.opam.template
                  ./jest
                  ./jest-dom
                  ./jest.config.js
                  ./package.json
                  ./package-lock.json
                ];
              };


            dontNpmBuild = true;
            npmDepsHash = "sha256-T0oSCDJtwK0vNwoQQBgRtgcrz/1/gfIEUaz2uHgVKKY=";
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
        in
        {
          inherit melange-jest;
          default = melange-jest;
        });
      devShells = forAllSystems (pkgs:
        let
          mkShell = { buildInputs ? [ ] }: pkgs.mkShell {
            inputsFrom = [ self.packages.${pkgs.system}.melange-jest ];
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
        {
          default = mkShell { };
          release = mkShell {
            buildInputs = with pkgs; [ cacert curl ocamlPackages.dune-release git ];
          };
        });
    };
}
