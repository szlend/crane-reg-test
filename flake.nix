{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, crane, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        lib = crane.mkLib pkgs;

        craneLib = lib.appendCrateRegistries [
          (lib.registryFromGitIndex {
            indexUrl = "https://github.com/Hirevo/alexandrie-index";
            rev = "d48a7f968d65aa5e4d469df101ca1cb513962879";
          })
          (lib.registryFromGitIndex {
            indexUrl = "https://github.com/szlend/alexandrie-index";
            rev = "e59401055ef4afbe7d3ec48580eb3718581a9ce5";
          })
        ];

        commonArgs = {
          src = craneLib.cleanCargoSource ./.;
          strictDeps = true;

          buildInputs = [
          ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
            pkgs.libiconv
          ];
        };

        my-crate = craneLib.buildPackage (commonArgs // {
          cargoArtifacts = craneLib.buildDepsOnly commonArgs;
        });
      in
      {
        packages.default = my-crate;
        devShells.default = craneLib.devShell { };
      });
}
