{ self
, config
, lib
, pkgs
, ...
}:

with lib;
let
  cfg = config.custom.streamdeck;
  inherit (lib.hm.gvariant) mkTuple mkUint32;

  page = {
    options = with types; {
      buttons = mkOption {
        type = attrsOf (submodule button);
        default = listToAttrs (map (idx: { name = toString idx; value = { }; }) [ 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 ]);
      };
    };
  };

  button = {
    options = with types; {
      text = mkOption {
        description = "Text to display on the button";
        type = str;
        default = "";
        example = "Mute Mic";
      };

      text_vertical_align = mkOption {
        description = "Alignment of the button text";
        type = enum [ "bottom" "middle-bottom" "middle" "middle-top" "top" ];
        default = "bottom";
        example = "middle-top";
      };

      icon = mkOption {
        description = "Path to an icon to display on the button";
        type = nullOr path;
        default = null;
      };

      brightness_change = mkOption {
        description = "Amount to change brightness by (positive or negative) when pressed";
        type = int;
        default = 0;
        example = -10;
      };

      switch_page = mkOption {
        description = "Page to switch to when pressed";
        type = nullOr (enum [ 0 1 2 3 4 5 6 7 8 9 ]);
        default = null;
        example = 2;
      };

      write = mkOption {
        description = "Text to write when pressed";
        type = lines;
        default = "";
        example = "Check out my Discord for more!";
      };

      command = mkOption {
        description = "Command to run when pressed";
        type = str;
        default = "";
      };

      keys = mkOption {
        description = "Keypresses to produce when pressed";
        type = str;
        default = "";
      };
    };
  };
in
{
  options.custom.streamdeck = with types; {
    enable = mkEnableOption "Declarative Stream Deck configuration";

    id = mkOption {
      description = "ID of the Stream Deck device";
      type = str;
      example = "ASDF69420QWERTY";
    };

    brightness = mkOption {
      description = "Current brightness";
      type = int;
      default = 99;
      example = 50;
    };

    page = mkOption {
      description = "Currently displayed page";
      type = int;
      default = 0;
      example = 1;
    };

    display_timeout = mkOption {
      description = "Display timeout in seconds";
      type = int;
      default = 0;
      example = 10;
    };

    brightness_dimmed = mkOption {
      description = "Percentage brightness to dim to when timed out";
      type = int;
      default = 60;
      example = 20;
    };

    pages = mkOption {
      type = attrsOf (submodule page);
      default = listToAttrs (map (idx: { name = toString idx; value = { }; }) [ 0 1 2 3 4 5 6 7 8 9 ]);
    };
  };

  config =
    let
      inherit (pkgs) writeShellScriptBin;

      streamdeck-scripts = [
      ];
    in
    mkIf cfg.enable {
      home.packages =
        let
          streamdeck-config = writeShellScriptBin
            "streamdeck-config"
            "systemctl stop --user streamdeck && ${pkgs.streamdeck-ui}/bin/streamdeck && systemctl start --user streamdeck";
        in
        with pkgs; [
          pulseaudio
          streamdeck-config
          streamdeck-ui
          xdotool
        ] ++ streamdeck-scripts;

      home.file.".streamdeck_ui_generated.json".text = builtins.toJSON {
        streamdeck_ui_version = 1;
        state = {
          "${cfg.id}" = {
            buttons = mapAttrs
              (_: value:
                mapAttrs
                  (_: value: value // {
                    text_vertical_align = if value.text_vertical_align == "bottom" then "" else value.text_vertical_align;
                    icon = toString value.icon;
                    switch_page = if value.switch_page == null then 0 else value.switch_page + 1;
                  })
                  value.buttons)
              cfg.pages;
            inherit (cfg) brightness page display_timeout brightness_dimmed;
          };
        };
      };

      systemd.user.services.streamdeck = {
        Unit = {
          Description = "Background streamdeck-ui process";
        };

        Install = {
          WantedBy = [ "multi-user.target" ];
        };

        Service = {
          Restart = "on-failure";
          RestartSec = "5s";

          ExecStart = "${pkgs.streamdeck-ui}/bin/streamdeck -n";

          Environment =
            let
              path = lib.makeBinPath (with pkgs; [
                pulseaudio
                xdotool
              ] ++ streamdeck-scripts);
            in
            [
              "PATH=${path}"
            ];
        };
      };
    };
}
