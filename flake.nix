# flake.nix
{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim?dir=nix";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    # Include any additional inputs if needed
    # For example:
    # neovim-nightly-overlay = {
    #   url = "github:nix-community/neovim-nightly-overlay";
    # };
  };

  outputs = { self, nixpkgs, nixCats, flake-utils, ... }@inputs:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; };
      # Import your nixcat-config.nix file
      nc = import ./nixcats-config.nix {inherit inputs;};
    in
    {
      # Outputs wrapped with ${system} by utils.eachSystem

      # Create packages from packageDefinitions
      # Define development shells
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          nc.nixosModules.default
        ];
      };
    };
}

