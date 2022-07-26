{ self
, config
, pkgs
, ...
}:

{
  services.avahi.nssmdns = true;

  networking.firewall.allowedTCPPorts = [
    # For CUPS
    631
  ];

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];
}
