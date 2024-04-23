{ lib
, pkgs
, modulesPath
, ...
}:

with lib;
with builtins;

{
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
  ];

  boot.kernelParams = [ "quiet" ];

  nix.nixPath = [
    "nixpkgs=${pkgs.path}"
  ];

  virtualisation = {
    cores = 2;
    memorySize = 1024 * 2;

    # Images will be in `/tmp`.
    emptyDiskImages = [
      (1 * 1024)
      (1 * 1024)
      (1 * 1024)
      (1 * 1024)
    ];
    diskSize = 2 * 1024;
    diskImage = "artifacts/vm.qcow2";
    qemu.diskInterface = "scsi";

    mountHostNixStore = true;
    writableStoreUseTmpfs = false;

    qemu.consoles = [ "console=tty1" ];
  };

  nixos-shell.mounts = {
    mountHome = false;
    mountNixProfile = false;
    cache = "none";
    extraMounts = {
      "/src" = {
        target = ./.;
        cache = "none";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "stargate" ''
      exec bash /src/src/stargate/main.sh "$@"
    '')
  ];

  environment.loginShellInit = ''
    export DEBUG=1

    alias exit='poweroff'

    # https://bash-prompt-generator.org/
    echo "export PS1='\n\[\e[1m\](Container) \n\[\033[1;31m\][\[\e]0;\u@\h: \w\a\]\u:\w]\$\[\033[0m\] '" >~/.profile

    cd /src
  '';

  services.getty = {
    autologinUser = mkForce "root";
    extraArgs = [
      "--skip-login"
      "--nonewline"
      "--noissue"
      "--noclear"
    ];
  };

  documentation.enable = false;
}
