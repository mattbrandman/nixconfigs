{ config, pkgs, inputs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  hardware.graphics.enable = true;
  # Login Manager
  # services.displayManager.sddm.enable = true; #This line enables sddm
  # services.displayManager.sddm.theme = "where_is_my_sddm_theme";
  # services.xserver.enable = true; # Might need this for Xwayland  

  # Enable the Flakes feature and the accompanying new nix command-line tool
  boot.loader.grub.device = "/dev/sda";   # (for BIOS systems only)
  boot.loader.systemd-boot.enable = true; # (for UEFI systems only)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  programs.hyprland.enable = true;
  environment.systemPackages = with pkgs; [
    # Flakes clones its dependencies through the git command,
    # so git must be installed first
    git
    # dunst
    mesa
    where-is-my-sddm-theme
    xdg-desktop-portal-gtk
    vim
    wget
    curl
    tmux
    alacritty
    kitty
    konsole
    mako
    libnotify
    libsForQt5.qt5ct
  ];
  pkgs.config.qt5 = {
    enable = true;
    platformTheme = "qt5ct"; 
      style = {
        package = pkgs.utterly-nord-plasma;
        name = "Utterly Nord Plasma";
      };
  };

  users.users.matt = {
    isNormalUser  = true;
    home  = "/home/matt";
    description  = "Matt";
    password = "dummy";
    extraGroups = [ "wheel" ];
  };

  # Set the default editor to vim
  nixCats.enable = true;
  environment.variables.EDITOR = "nvim";

  # Virtualisation Settings
  virtualisation.vmware.guest.enable = true;
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_RENDERER_ALLOW_SOFTWARE= "1";
    LIBGL_ALWAYS_SOFTWARE = "1";
  };
  # xdg.portal.enable = true;
  # qt.enable = true;
  # programs.hyprland.xwayland.enable = true;
  # services.mako.enable = true;
  # ......
}
