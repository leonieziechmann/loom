{
  description = "loom dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    tytanic = {
      url = "github:typst-community/tytanic/v0.3.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, pre-commit-hooks, tytanic }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      toml = builtins.fromTOML (builtins.readFile ./typst.toml);
      name = toml.package.name;
      version = toml.package.version;

      linkPackageHook = ''
        export XDG_DATA_HOME="$PWD/.typst-data"
        export XDG_CACHE_HOME="$PWD/.typst-cache"

        PKG_DIR="$XDG_DATA_HOME/typst/packages/preview/${name}/${version}"

        # Only print if we are in an interactive shell (optional, keeps CI logs clean)
        if [ -t 1 ]; then
          echo "✨ Setting up Loom build environment..."
        fi

        mkdir -p "$(dirname "$PKG_DIR")"
        rm -rf "$PKG_DIR"
        ln -s "$PWD" "$PKG_DIR"
      '';
    in
    {
      checks.${system}.pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          typstyle = {
            enable = true;
            name = "typstyle";
            entry = "${pkgs.typstyle}/bin/typstyle -i";
            files = "\\.typ$";
          };
          prettier = {
            enable = true;
            types_or = [ "markdown" ];
          };
          nixpkgs-fmt.enable = true;
        };
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          typst
          typstyle
          markdownlint-cli
          nodePackages.prettier
          nodejs
          yarn
          tytanic.packages.${system}.default
        ] ++ self.checks.${system}.pre-commit-check.enabledPackages;

        shellHook = ''
          ${self.checks.${system}.pre-commit-check.shellHook}
          ${linkPackageHook}
          echo "✔  Package linked! You can now use: #import \"@preview/${name}:${version}\": *"
        '';
      };

      docs = pkgs.mkShell {
        buildInputs = [ pkgs.nodejs pkgs.typst ];
        shellHook = linkPackageHook;
      };
    };
}
