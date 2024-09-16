# flake.nix
{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim?dir=nix";
    flake-utils.url = "github:numtide/flake-utils";

    # Include any additional inputs if needed
    # For example:
    # neovim-nightly-overlay = {
    #   url = "github:nix-community/neovim-nightly-overlay";
    # };
  };

  outputs = { self, nixpkgs, nixCats, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        # Import your nixcat-config.nix file
        nc = import ./nixcats-config.nix { inherit inputs; };
      in
      {
        # Outputs wrapped with ${system} by utils.eachSystem

        # Create packages from packageDefinitions
        # Define development shells
        nixosConfigurations.root = nixpkgs.lib.nixosSystem {
          modules = [
            ./configuration.nix
            nc.nixosModules
          ];
        };
        devShells = {
          default = pkgs.mkShell {
            buildInputs = [ nc.packages.${system}.nixCats ];
            inputsFrom = [ ];
            shellHook = ''
        '';
          };
        };
      });
}

