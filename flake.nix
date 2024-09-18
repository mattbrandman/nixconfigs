# flake.nix
{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim?dir=nix";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    # Include any additional inputs if needed
    # For example:
    # neovim-nightly-overlay = {
    #   url = "github:nix-community/neovim-nightly-overlay";
    # };
  };

  outputs = { self, chaotic, nixpkgs, nixCats, flake-utils, ... }@inputs:
    let
      system = "aarch64-linux";
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
          chaotic.nixosModules.default
        ];
      };
    };
}

