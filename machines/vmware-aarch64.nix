{ config, pkgs, inputs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  services.displayManager.sddm.enable = true; #This line enables sddm
  services.xserver.displayManager.sddm.enable = true; #This line enables sddm
  # Enable the Flakes feature and the accompanying new nix command-line tool
  boot.loader.grub.device = "/dev/sda";   # (for BIOS systems only)
  boot.loader.systemd-boot.enable = true; # (for UEFI systems only)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  programs.hyprland.enable = true;
  environment.systemPackages = with pkgs; [
    # Flakes clones its dependencies through the git command,
    # so git must be installed first
    git
    vim
    wget
    curl
    qt6.qtwayland
    tmux
    alacritty
    kitty
  ];

  # Set the default editor to vim
  nixCats.enable = true;
  environment.variables.EDITOR = "nvim";

  # Virtualisation Settings
  virtualisation.vmware.guest.enable = true;
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_RENDERER_ALLOW_SOFTWARE= "1";
  };


  # ......
}
