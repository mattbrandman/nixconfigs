{ config, pkgs, inputs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Cache Settings
  # configuration.nix

  # this needs to be active before hyprland TODO: make this automated somehow? https://discourse.nixos.org/t/how-to-set-up-cachix-in-flake-based-nixos-config/31781/3
  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS=1;
  };

  programs.hyprland = {
    enable = true;
    # set the flake package
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # make sure to also set the portal package, so that they are in sync
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  # Enable the Flakes feature and the accompanying new nix command-line tool
  boot.loader.grub.device = "/dev/vda";   # (for BIOS systems only)
  boot.loader.systemd-boot.enable = true; # (for UEFI systems only)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.systemPackages = with pkgs; [
    # Flakes clones its dependencies through the git command,
    # so git must be installed first
    git
    vim
    wget
    curl
    kitty
  ];
  # Set the default editor to vim
  nixCats.enable = true;
  hardware.opengl.enable = true;
  environment.variables.EDITOR = "nvim";

  # ......
}
