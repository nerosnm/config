{ self
, ...
}:

{
  custom.streamdeck = {
    enable = true;
    id = "AL02K2C00411";
    brightness = 100;

    pages =
      let
        inherit (builtins) listToattrs map toString;
      in
      {
        "0".buttons = {
          "1" = {
            icon = ./icons/streamos/classic-2/w95-misc-home.png;
            switch_page = 1;
          };
          "2".icon = ./icons/streamos/transparent/w95-hotkey-off.png;
          "3".icon = ./icons/streamos/transparent/w95-hotkey-off.png;
          "6".icon = ./icons/streamos/transparent/w95-hotkey-off.png;
          "7".icon = ./icons/streamos/transparent/w95-hotkey-off.png;
          "8".icon = ./icons/streamos/transparent/w95-hotkey-off.png;
          "11".icon = ./icons/streamos/transparent/w95-hotkey-off.png;
          "12".icon = ./icons/streamos/transparent/w95-hotkey-off.png;
          "13".icon = ./icons/streamos/transparent/w95-hotkey-off.png;

          "4" = {
            icon = ./icons/streamos/transparent/w95-light-brighter.png;
            brightness_change = 25;
          };

          "14" = {
            icon = ./icons/streamos/transparent/w95-light-dimmer.png;
            brightness_change = -25;
          };
        };

        "1".buttons = {
          "2" = {
            icon = ./icons/streamos/cyber/w95-misc-open.png;
            switch_page = 0;
          };

          "1" = {
            icon = ./icons/streamos/classic-2/w95-mic-off.png;
            command = "xdotool key shift+ctrl+alt+super+m";
          };
        };

        "2".buttons = {
          "2" = {
            icon = ./icons/streamos/cyber/w95-misc-open.png;
            switch_page = 0;
          };
        };

        "3".buttons = {
          "2" = {
            icon = ./icons/streamos/cyber/w95-misc-open.png;
            switch_page = 0;
          };
        };

        "4".buttons = {
          "2" = {
            icon = ./icons/streamos/cyber/w95-misc-open.png;
            switch_page = 0;
          };
        };

        "5".buttons = {
          "2" = {
            icon = ./icons/streamos/cyber/w95-misc-open.png;
            switch_page = 0;
          };
        };

        "6".buttons = {
          "2" = {
            icon = ./icons/streamos/cyber/w95-misc-open.png;
            switch_page = 0;
          };
        };

        "7".buttons = {
          "2" = {
            icon = ./icons/streamos/cyber/w95-misc-open.png;
            switch_page = 0;
          };
        };

        "8".buttons = {
          "2" = {
            icon = ./icons/streamos/cyber/w95-misc-open.png;
            switch_page = 0;
          };
        };

        "9".buttons = {
          "2" = {
            icon = ./icons/streamos/cyber/w95-misc-open.png;
            switch_page = 0;
          };
        };
      };
  };
}
