{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.nerosnm.services.loki;
  home = "/srv/loki";

  inherit (lib) mkIf;
in
{
  options = with lib; {
    nerosnm.services.loki = {
      enable = mkEnableOption "Loki";

      port = mkOption rec {
        description = ''
          Port for Loki to listen over.
        '';
        type = types.int;
        default = 9003;
        example = default;
      };

      promtail = {
        port = mkOption rec {
          description = ''
            Port for Promtail to listen over.
          '';
          type = types.int;
          default = 9004;
          example = default;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services.loki = {
      enable = true;
      dataDir = home;

      configuration = {
        server.http_listen_port = cfg.port;
        auth_enabled = false;

        ingester = {
          lifecycler = {
            address = "127.0.0.1";
            ring = {
              kvstore = {
                store = "inmemory";
              };
              replication_factor = 1;
            };
          };
          chunk_idle_period = "1h";
          max_chunk_age = "1h";
          chunk_target_size = 999999;
          chunk_retain_period = "30s";
          max_transfer_retries = 0;
        };

        schema_config = {
          configs = [{
            from = "2022-06-06";
            store = "boltdb-shipper";
            object_store = "filesystem";
            schema = "v11";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }];
        };

        storage_config = {
          boltdb_shipper = {
            active_index_directory = "${home}/boltdb-shipper-active";
            cache_location = "${home}/boltdb-shipper-cache";
            cache_ttl = "24h";
            shared_store = "filesystem";
          };

          filesystem = {
            directory = "${home}/chunks";
          };
        };

        limits_config = {
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
        };

        chunk_store_config = {
          max_look_back_period = "0s";
        };

        table_manager = {
          retention_deletes_enabled = false;
          retention_period = "0s";
        };

        compactor = {
          working_directory = home;
          shared_store = "filesystem";
          compactor_ring = {
            kvstore = {
              store = "inmemory";
            };
          };
        };
      };
    };

    services.promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = cfg.promtail.port;
          grpc_listen_port = 0;
        };
        positions = {
          filename = "/tmp/positions.yaml";
        };
        clients = [{
          url = "http://127.0.0.1:${toString cfg.port}/loki/api/v1/push";
        }];
        scrape_configs = [{
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = config.networking.hostName;
            };
          };
          relabel_configs = [{
            source_labels = [ "__journal__systemd_unit" ];
            target_label = "unit";
          }];
        }];
      };
    };
  };
}
