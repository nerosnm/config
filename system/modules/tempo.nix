{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.nerosnm.services.tempo;

  home = "/srv/tempo";
  settingsFormat = pkgs.formats.yaml { };

  inherit (lib) mkIf;
in
{
  options = with lib; {
    nerosnm.services.tempo = {
      enable = mkEnableOption "Tempo";

      port = mkOption rec {
        description = ''
          HTTP listen port for Tempo.
        '';
        type = types.int;
        default = 9005;
        example = default;
      };

      grpcPort = mkOption rec {
        description = ''
          gRPC listen port for Tempo.
        '';
        type = types.int;
        default = 9006;
        example = default;
      };

      otlpReceiverPort = mkOption rec {
        description = ''
          Port for the Tempo OTLP receiver.
        '';
        type = types.int;
        default = 4317;
        example = default;
      };
    };
  };

  config = mkIf cfg.enable {
    services.tempo = {
      inherit (cfg) enable;

      settings = {
        server = {
          http_listen_port = cfg.port;
          grpc_listen_port = cfg.grpcPort;
        };

        distributor = {
          receivers = {
            otlp = {
              protocols = {
                grpc = {
                  endpoint = "0.0.0.0:${toString cfg.otlpReceiverPort}";
                };
              };
            };
          };
        };

        ingester = {
          trace_idle_period = "10s";
          max_block_bytes = 100000;
          max_block_duration = "1m";
        };

        compactor = {
          compaction = {
            compaction_window = "1h";
            max_block_bytes = 100000000;
            block_retention = "1h";
            compacted_block_retention = "10m";
          };
        };

        storage = {
          trace = {
            backend = "local";
            block = {
              bloom_filter_false_positive = .05;
              # index_downsample_bytes = 1000;
              # encoding = "zstd";
            };
            wal = {
              path = "/tmp/tempo/wal";
              # encoding = "snappy";
            };
            local = {
              path = "/tmp/tempo/blocks";
            };
            pool = {
              max_workers = 100;
              queue_depth = 10000;
            };
          };
        };
      };
    };
  };
}
