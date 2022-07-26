{ self
, config
, lib
, pkgs
, profiles
, suites
, ...
}:

{
  imports = suites.home ++ (with profiles; [
    moonlander.nixos
    music.nixos
    printing.nixos
    stream.nixos
    tailscale.nixos
  ]);

  boot = {
    # Set up the boot loader.
    loader = {
      # Enable systemd-boot.
      systemd-boot.enable = true;

      efi.canTouchEfiVariables = true;

      # According to the ZFS instructions for NixOS, this is important, but I'm
      # not using GRUB, so it seems pointless.
      grub.copyKernels = true;
    };

    # We can't allow hibernation when using ZFS.
    kernelParams = [ "nohibernate" ];

    supportedFilesystems = [ "zfs" ];
    zfs.devNodes = "/dev/";

    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ ];

      # Erase your darlings!
      postDeviceCommands = lib.mkAfter ''
        zfs rollback -r tank/system/talitha/root@blank
      '';
    };

    kernelModules = [
      "kvm-amd"
      "v4l2loopback"

      "zenpower"
    ];
    blacklistedKernelModules = [
      # Don't load this together with zenpower
      "k10temp"
    ];

    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback.out
      zenpower
    ];
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 max_buffers=2
      options snd_usb_audio vid=0x1235 pid=0x8210 device_setup=1
    '';

    # Explicitly set the kernel version.
    # kernelPackages = pkgs.linuxKernel.packages.linux_5_17;
  };

  services.zfs = {
    trim.enable = true;
    autoSnapshot.enable = true;

    autoScrub = {
      enable = true;
      pools = [ "tank" ];
    };
  };

  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-uuid/E342-2D72";
      fsType = "vfat";
      options = [ "X-mount.mkdir" ];
    };

    "/boot-fallback" = {
      device = "/dev/disk/by-uuid/131F-144F";
      fsType = "vfat";
      options = [ "X-mount.mkdir" ];
    };

    "/" = {
      device = "tank/system/talitha/root";
      fsType = "zfs";
    };

    "/nix" = {
      device = "tank/local/nix";
      fsType = "zfs";
    };

    "/var/log" = {
      device = "tank/system/talitha/log";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/home" = {
      device = "tank/safe/talitha/home";
      fsType = "zfs";
    };

    "/persist" = {
      device = "tank/safe/talitha/persist";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/var/lib/tailscale" = {
      device = "tank/safe/talitha/persist/tailscale";
      fsType = "zfs";
    };
  };

  # Have sudo store its lecture status files under /persist, otherwise I'll get 
  # lectured about sudo after every reboot.
  security.sudo.extraConfig = ''
    Defaults lecture_status_dir=/persist/sudo/lectured
  '';

  swapDevices = [
    {
      device = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_1TB_S6P7NS0T212380X-part2";
      randomEncryption = true;
    }
    {
      device = "/dev/disk/by-id/ata-Hitachi_HDS721010CLA330_JP2911N03RKUPV-part2";
      randomEncryption = true;
    }
  ];

  # This machine dual-boots NixOS and Windows, so because Windows insists on 
  # storing the
  # time in the hardware clock using local time, we need to make NixOS do the same thing
  # (the default is to use UTC, which is frankly much more sensible). Otherwise, the clock
  # will be messed up every time we switch between NixOS and Windows.
  time.hardwareClockInLocalTime = true;

  environment.etc."machine-id".text = "ba3613eb0aa643c3827910f88c4b1b63";
  networking = {
    hostId = "350ab187";

    useDHCP = lib.mkDefault true;

    firewall = {
      enable = true;

      # Expose the SSH port to the public internet
      allowedTCPPorts = [ 22 ];
    };

    interfaces.enp42s0.macAddress = "ea:db:c6:ec:b4:06";
  };

  # For the tailscale profile
  age.secrets.tailscale-authkey.file = "${self}/secrets/tailscale-talitha.age";

  services.openssh = {
    enable = true;

    hostKeys = [
      {
        path = "/persist/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
      {
        path = "/persist/ssh/ssh_host_rsa_key";
        type = "rsa";
        bits = 4096;
      }
    ];

    extraConfig = ''
      StreamLocalBindUnlink yes
    '';
  };

  # Enable Pipewire to replace (and emulate!) ALSA.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    config.pipewire =
      let
        quant = 128;
      in
      {
        "context.properties" = {
          "link.max-buffers" = 16;
          "log.level" = 2;
          "default.clock.rate" = 48000;
          "default.clock.quantum" = quant;
          "default.clock.min-quantum" = quant;
          "default.clock.max-quantum" = quant;
          "core.daemon" = true;
          "core.name" = "pipewire-0";
        };
        "context.modules" = [
          {
            name = "libpipewire-module-rtkit";
            args = {
              "nice.level" = -15;
              "rt.prio" = 88;
              "rt.time.soft" = 200000;
              "rt.time.hard" = 200000;
            };
            flags = [ "ifexists" "nofail" ];
          }
          { name = "libpipewire-module-protocol-native"; }
          { name = "libpipewire-module-profiler"; }
          { name = "libpipewire-module-metadata"; }
          { name = "libpipewire-module-spa-device-factory"; }
          { name = "libpipewire-module-spa-node-factory"; }
          { name = "libpipewire-module-client-node"; }
          { name = "libpipewire-module-client-device"; }
          {
            name = "libpipewire-module-portal";
            flags = [ "ifexists" "nofail" ];
          }
          {
            name = "libpipewire-module-access";
            args = { };
          }
          { name = "libpipewire-module-adapter"; }
          { name = "libpipewire-module-link-factory"; }
          { name = "libpipewire-module-session-manager"; }
        ];
      };
  };
  # Disable default ALSA-based sound.
  hardware.pulseaudio.enable = false;
  # Allow PulseAudio to acquire realtime priority.
  security.rtkit.enable = true;

  # Use the Nvidia video driver in X.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
  hardware.opengl.driSupport32Bit = true;

  # services.xserver.displayManager.setupCommands = ''
  #   ${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --primary --mode 2560x1440 --rate 74.99 --output DP-0 --mode 2560x1440 --right-of DP-2 --rate 74.97
  # '';

  systemd.services.eos-webcam = {
    enable = true;

    wantedBy = [ ];

    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "5s";
    };

    script = ''
      ${pkgs.gphoto2}/bin/gphoto2 --stdout --capture-movie | ${pkgs.ffmpeg}/bin/ffmpeg -i - -vcodec rawvideo -pix_fmt yuv420p -f v4l2 /dev/video0
    '';
  };

  # Use the performance CPU freq governor.
  powerManagement.cpuFreqGovernor = "performance";

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.video.hidpi.enable = lib.mkDefault true;

  systemd.tmpfiles.rules = [
    "L+ /run/gdm/.config/monitors.xml - - - - ${pkgs.writeText "gdm-monitors.xml" ''
      <monitors version="2">
        <configuration>
          <logicalmonitor>
            <x>0</x>
            <y>0</y>
            <scale>1</scale>
            <primary>yes</primary>
            <monitor>
              <monitorspec>
                <connector>DP-2</connector>
                <vendor>LEN</vendor>
                <product>Q27q-1L</product>
                <serial>UBP0B12X</serial>
              </monitorspec>
              <mode>
                <width>2560</width>
                <height>1440</height>
                <rate>74.990730285644531</rate>
              </mode>
            </monitor>
          </logicalmonitor>
          <logicalmonitor>
            <x>2560</x>
            <y>0</y>
            <scale>1</scale>
            <monitor>
              <monitorspec>
                <connector>DP-0</connector>
                <vendor>LEN</vendor>
                <product>LEN Q27h-10</product>
                <serial>U5B39B05</serial>
              </monitorspec>
              <mode>
                <width>2560</width>
                <height>1440</height>
                <rate>74.970916748046875</rate>
              </mode>
            </monitor>
          </logicalmonitor>
        </configuration>
        <configuration>
          <logicalmonitor>
            <x>0</x>
            <y>0</y>
            <scale>1</scale>
            <primary>yes</primary>
            <monitor>
              <monitorspec>
                <connector>DP-0</connector>
                <vendor>LEN</vendor>
                <product>Q27q-1L</product>
                <serial>UBP0B12X</serial>
              </monitorspec>
              <mode>
                <width>2560</width>
                <height>1440</height>
                <rate>74.990730285644531</rate>
              </mode>
            </monitor>
          </logicalmonitor>
          <logicalmonitor>
            <x>2560</x>
            <y>0</y>
            <scale>1</scale>
            <monitor>
              <monitorspec>
                <connector>DP-2</connector>
                <vendor>LEN</vendor>
                <product>LEN Q27h-10</product>
                <serial>U5B39B05</serial>
              </monitorspec>
              <mode>
                <width>2560</width>
                <height>1440</height>
                <rate>74.970916748046875</rate>
              </mode>
            </monitor>
          </logicalmonitor>
        </configuration>
      </monitors>
    ''}"
  ];

  # This value determines the NixOS release from which the default settings for 
  # stateful data, like file locations and database versions on your system were 
  # taken. It‘s perfectly fine and recommended to leave this value at the 
  # release version of the first install of this system.
  # 
  # Before changing this value read the documentation for this option (e.g. man 
  # configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
