{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.custom.irc;

  inherit (builtins) length;
  inherit (lib) concatStrings concatStringsSep mapAttrs' mapAttrsToList mkIf optional;
in
{
  options.custom.irc = with lib; {
    enable = mkEnableOption "catgirl IRC server configuration";

    servers = mkOption {
      description = "List of IRC servers";
      type = types.attrsOf (types.submodule {
        options = {
          host = mkOption {
            description = "Hostname of the server";
            type = types.nullOr types.str;
            default = null;
            example = "irc.eu.libera.chat";
          };
          nick = mkOption {
            description = "Nick to use in this server";
            type = types.nullOr types.str;
            default = null;
            example = "username";
          };
          real = mkOption {
            description = "Real name to use in this server";
            type = types.nullOr types.str;
            default = null;
            example = "name (pron/ouns)";
          };
          join = mkOption {
            description = "List of channels to automatically join";
            type = types.listOf types.str;
            default = [ ];
            example = [ "#nixos" "#coffee" ];
          };
          pass = mkOption {
            description = "Server pass";
            type = types.nullOr types.str;
            default = null;
          };
          cert = mkOption {
            description = "SASL external certificate";
            type = types.nullOr types.path;
            default = null;
          };
          notify = mkEnableOption "notifications with libnotify";
          quiet = mkEnableOption ''
            Raise the default message visibility threshold for new windows, 
            hiding general events (joins, quits, etc.).
          '';
          _16color = mkEnableOption ''
            Restrict the maximum IRC colour value to use only colours from the 
            16-colour terminal set.
          '';
        };
      });
      default = { };
    };
  };

  config = mkIf cfg.enable {
    xdg.configFile = mapAttrs'
      (name: server: {
        name = "catgirl/${name}";
        value = {
          text = concatStrings (optional (server.host != null) ''
            host = ${server.host}
          '' ++ optional (server.nick != null) ''
            nick = ${server.nick}
          '' ++ optional (server.real != null) ''
            real = ${server.real}
          '' ++ optional ((length server.join) > 0) ''
            join = ${concatStringsSep "," server.join}
          '' ++ optional (server.pass != null) ''
            pass = ${server.pass}
          '' ++ optional (server.cert != null) ''
            cert = ${server.cert}
            sasl-external
          '' ++ optional server.notify ''
            notify = ${pkgs.libnotify}/bin/notify-send
          '' ++ optional server.quiet ''
            quiet
          '' ++ optional server._16color ''
            hash = 0,15
          '');
        };
      })
      cfg.servers;

    assertions = mapAttrsToList
      (name: server: {
        assertion = (server.pass != null) -> (server.cert == null);
        message = "Server ${name} must not have both a pass and a cert specified";
      })
      cfg.servers;
  };
}
