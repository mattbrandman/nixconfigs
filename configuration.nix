{ config, pkgs, inputs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Cache Settings
  # configuration.nix
  virtualisation.vmware.guest.enable = true;
  # this needs to be active before hyprland TODO: make this automated somehow? https://discourse.nixos.org/t/how-to-set-up-cachix-in-flake-based-nixos-config/31781/3
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_RENDERER_ALLOW_SOFTWARE= "1";
  };
  # services.spice-vdagentd.enable = true;
  # services.qemuGuest.enable = true;
  # services.xserver.enable = true;

  # Enable the Flakes feature and the accompanying new nix command-line tool
  boot.loader.grub.device = "/dev/vda";   # (for BIOS systems only)
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
  ];
  # Set the default editor to vim
  # nixCats.enable = true;
  environment.variables.EDITOR = "nvim";

  # ......
}
