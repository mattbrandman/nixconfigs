# flake.nix
{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats.url = "github:BirdeeHub/nixCats-nvim?dir=nix";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:danth/stylix";
    # hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    # Include any additional inputs if needed
    # For example:
    # neovim-nightly-overlay = {
    #   url = "github:nix-community/neovim-nightly-overlay";
    # };
  };

  outputs = { self, nixpkgs, nixCats, home-manager, stylix, ... }@inputs:
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
      nixpkgs.config.allowUnfree = true;
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          stylix.nixosModules.stylix
          ./machines/vmware-aarch64.nix
          nc.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.matt = import ./home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
      };
      nixosConfigurations.vm-aarch64 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./machines/vmware-aarch64.nix
          nc.nixosModules.default
        ];
      };
    };
}

