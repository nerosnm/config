{
  # Expose the HTTP and HTTPS ports to the public internet
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  # Set up an HTTPS certificate for gemmat.dev
  security.acme.certs."gemmat.dev".email = "gemtipper@gmail.com";

  # Make sure nginx is enabled and set up a virtual host that redirects every
  # request to the same path under ninthroad.neocities.org.
  services.nginx.enable = true;
  services.nginx.virtualHosts."gemmat.dev" = {
    enableACME = true;
    forceSSL = true;

    locations."/" = {
      return = "301 $scheme://ninthroad.neocities.org$request_uri";
    };
  };
}
