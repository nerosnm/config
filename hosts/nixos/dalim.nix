{ self
, config
, lib
, pkgs
, profiles
, suites
, ...
}:

{
  imports = suites.work ++ (with profiles; [
    moonlander.nixos
    printing.nixos
    quay-ditto
    social.nixos
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
        zfs rollback -r tank/system/dalim/root@blank
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
    '';

    # Explicitly set the kernel version.
    # kernelPackages = pkgs.linuxKernel.packages.linux_5_17;
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;

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
      device = "tank/system/dalim/root";
      fsType = "zfs";
    };

    "/nix" = {
      device = "tank/local/nix";
      fsType = "zfs";
    };

    "/var/log" = {
      device = "tank/system/dalim/log";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/home" = {
      device = "tank/safe/dalim/home";
      fsType = "zfs";
    };

    "/persist" = {
      device = "tank/safe/dalim/persist";
      fsType = "zfs";
      neededForBoot = true;
    };

    "/var/lib/tailscale" = {
      device = "tank/safe/dalim/persist/tailscale";
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

  environment.etc."machine-id".text = "bc9b62da141f49e3b52d54c682845ee1";
  networking = {
    hostId = "31dca186";

    useDHCP = lib.mkDefault true;

    firewall = {
      enable = true;

      # Expose the SSH port to the public internet
      allowedTCPPorts = [ 22 ];
    };

    interfaces.enp42s0.macAddress = "ae:54:f4:33:81:ad";
  };

  # For the tailscale profile
  # age.secrets.tailscale-authkey.file = "${self}/secrets/tailscale-dalim.age";

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

  services.buildkite.enable = true;

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
  system.stateVersion = "22.11"; # Did you read the comment?
}
