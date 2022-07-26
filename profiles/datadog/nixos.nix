{ self
, pkgs
, config
, ...
}:

{
  services.datadog-agent = {
    enable = true;
    hostname = config.networking.hostName;

    apiKeyFile = "/run/agenix/datadog-api-key";
    site = "datadoghq.eu";
    enableTraceAgent = true;

    extraConfig = {
      logs_enabled = true;
      site = "datadoghq.eu";
    };
  };

  age.secrets.datadog-api-key.file = "${self}/secrets/datadog-api-key.age";

  environment.etc."datadog-agent/conf.d/neros-dev-dev.d/conf.yaml".text = ''
    logs:
      - type: tcp
        port: 10518
        service: "neros-dev-dev"
        source: "neros-dev-dev"
  '';
}
