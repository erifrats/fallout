# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ lib, pkgs, config, self, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./disk-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable support for other filesystems.
  boot.supportedFilesystems = [ "btrfs" "ntfs" ];

  # Define your hostname.
  networking.hostName = "stargate";

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";
  services.automatic-timezoned.enable = true; # Or toggle automatic timezone.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Enable the Budgie Desktop Environment.
  # services.xserver.desktopManager.budgie.enable = true;
  # services.xserver.displayManager.lightdm.enable = true;

  # Enable Nvidia Drivers for XServer.
  # services.xserver.videoDrivers = [ "nvidia" ];

  # You will next need to determine the appropriate driver version for your card. The following options are available:
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.production; # (installs 550)
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.vulkan_beta;
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_390;
  # hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_340;

  # Enable AMD Drivers for XServer.
  # services.xserver.videoDrivers = [ "amdgpu" ];

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Define a user account.
  users.users."{{ USERNAME }}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    hashedPassword = "{{ HASHED_PASSWORD }}";
    packages = with pkgs; lib.mkIf config.services.xserver.enable [
      firefox
      vscodium.fhs
      keepassxc
      gsmartcontrol
      gparted
    ];
  };

  # Enable experimental features for Nix, including `nix-command` and `flakes`.
  # For more information, see the Nix manual at https://nixos.org/manual/nix/stable/options.html#opt-nix.settings.experimental-features.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    tree
    xclip

    # Development
    git
    lazygit
    devbox
    nil
    direnv
    helix
    zellij
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # The multicast DNS (mDNS) protocol resolves hostnames to IP addresses
  # within small networks that do not include a local name server. It is a
  # zero-configuration service, using essentially the same programming interfaces,
  # packet formats and operating semantics as unicast Domain Name System (DNS).
  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
    };
  };

  system.autoUpgrade = {
    enable = true;
    dates = "daily";
    persistent = true;
    flake = self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L" # print build logs
    ];
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "{{ VERSION_ID }}"; # Did you read the comment?
}
