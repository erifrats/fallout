# For more information, see https://github.com/nix-community/disko

{
  disko.devices = {
    disk = {
      nixos = {
        type = "disk";
        device = "{{ DISK }}";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "defaults" ];
              };
            };

            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypto";
                extraOpenArgs = [ ];
                settings = {
                  allowDiscards = true;
                };
                passwordFile = "{{ LUKS_FILE }}";
                content = {
                  type = "lvm_pv";
                  vg = "nixos";
                };
              };
            };
          };
        };
      };
    };

    lvm_vg = {
      nixos = {
        type = "lvm_vg";

        lvs = {
          swap = {
            size = "8GB";
            content = {
              type = "swap";
              resumeDevice = true;
            };
          };

          root = {
            size = "100%FREE";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ]; # Override existing partition
              mountpoint = "/";

              # https://btrfs.readthedocs.io/en/latest/Administration.html#mount-options
              mountOptions = [
                "compress=zstd"
                "noatime"
                "autodefrag"
              ];
            };
          };
        };
      };
    };
  };
}
