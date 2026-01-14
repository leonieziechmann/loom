{
  description = "loom dev environment";

  nixConfig = {
    extra-substituters = [ "https://typ-flow.cachix.org" ];
    extra-trusted-public-keys = [ "typ-flow.cachix.org-1:WEY45Irm+quH9n4ENB5rOxkdxfgkTcB3iMtdaADjf9s=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    flake-utils.url = "github:numtide/flake-utils";
    tytanic.url = "github:typst-community/tytanic/v0.3.3";
    typst-utils.url = "github:leonieziechmann/typst-nix-utils";
  };

  outputs = { self, nixpkgs, pre-commit-hooks, flake-utils, tytanic, typst-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        toml = builtins.fromTOML (builtins.readFile ./typst.toml);
        name = toml.package.name;
        version = toml.package.version;

        loomPackage = typst-utils.lib.buildTypstPackage {
          inherit pkgs;
          pname = toml.package.name;
          version = toml.package.version;
          src = ./.;
          files = [ "typst.toml" "lib.typ" "src" "LICENSE" ];
        };

        typstEnv = typst-utils.lib.mkTypstEnv {
          inherit pkgs;
          typst = pkgs.typst;
          packages = [
            loomPackage
          ];
        };
      in
      {
        packages.default = loomPackage;

        checks.pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            typstyle = { enable = true; name = "typstyle"; entry = "${pkgs.typstyle}/bin/typstyle -i"; files = "\\.typ$"; };
            prettier = { enable = true; types_or = [ "markdown" ]; };
            nixpkgs-fmt.enable = true;
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            typstEnv
            typstyle
            markdownlint-cli
            nodePackages.prettier
            nodejs
            yarn
            tytanic.packages.${system}.default
          ] ++ self.checks.${system}.pre-commit-check.enabledPackages;

          shellHook = ''
            ${self.checks.${system}.pre-commit-check.shellHook}
            echo "✔  Package linked! You can now use: #import \"@preview/${name}:${version}\": *"
          '';
        };

        docs = pkgs.mkShell {
          buildInputs = with pkgs; [ nodejs typst ];
        };
      }
    );
}
