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
          "2" = {
            icon = ./icons/streamos/classic-2/w95-obs.png;
            switch_page = 2;
          };
          "3" = {
            icon = ./icons/streamos/classic-2/w95-discord.png;
            switch_page = 3;
          };
          "6".icon = ./icons/streamos/transparent/w95-hotkey-off.png;
          "7".icon = ./icons/streamos/transparent/w95-hotkey-off.png;
          "8".icon = ./icons/streamos/transparent/w95-hotkey-off.png;
          "11" = {
            icon = ./icons/streamos/classic-2/w95-adobe-photoshop.png;
            switch_page = 7;
          };
          "12".icon = ./icons/streamos/transparent/w95-hotkey-off.png;
          "13".icon = ./icons/streamos/transparent/w95-hotkey-off.png;

          "4" = {
            icon = ./icons/streamos/transparent/w95-light-brighter.png;
            brightness_change = 25;
          };

          "9" = {
            icon = ./icons/streamos/transparent/w95-power-off.png;
            command = "xdotool key shift+super+l";
          };

          "14" = {
            icon = ./icons/streamos/transparent/w95-light-dimmer.png;
            brightness_change = -25;
          };
        };

        "1".buttons = {
          "2" = {
            icon = ./icons/streamos/transparent/w95-misc-home.png;
            switch_page = 0;
          };
          "4" = {
            icon = ./icons/streamos/transparent/w95-misc-next.png;
            switch_page = 2;
          };

          "1" = {
            icon = ./icons/streamos/classic-2/w95-mic-off.png;
            command = "xdotool key shift+super+k";
          };
          "3" = {
            icon = ./icons/streamos/classic/w95-mic-off.png;
            command = "xdotool key shift+super+m";
          };

          "7" = {
            icon = ./icons/streamos/classic/w95-spotify.png;
            command = "playerctl --player spotify play-pause";
          };
          "6" = {
            icon = ./icons/streamos/classic/w95-mm-prev.png;
            command = "playerctl --player spotify previous";
          };
          "8" = {
            icon = ./icons/streamos/classic/w95-mm-next.png;
            command = "playerctl --player spotify next";
          };
          "0" = {
            icon = ./icons/streamos/classic/w95-mm-volume-up.png;
            command = "playerctl --player spotify volume 0.1+";
          };
          "5" = {
            icon = ./icons/streamos/classic/w95-mm-volume-down.png;
            command = "playerctl --player spotify volume 0.1-";
          };

          "10" = {
            icon = ./icons/streamos/classic-2/w95-scene-1-off.png;
            command = "xdotool set_desktop 0";
          };
          "11" = {
            icon = ./icons/streamos/classic-2/w95-scene-2-off.png;
            command = "xdotool set_desktop 1";
          };
          "12" = {
            icon = ./icons/streamos/classic-2/w95-scene-3-off.png;
            command = "xdotool set_desktop 2";
          };
          "13" = {
            icon = ./icons/streamos/classic-2/w95-scene-4-off.png;
            command = "xdotool set_desktop 3";
          };
          "14" = {
            icon = ./icons/streamos/classic-2/w95-scene-5-off.png;
            command = "xdotool set_desktop 4";
          };
        };

        "2".buttons = {
          "0" = {
            icon = ./icons/streamos/transparent/w95-misc-previous.png;
            switch_page = 1;
          };
          "2" = {
            icon = ./icons/streamos/transparent/w95-obs.png;
            switch_page = 0;
          };
          "4" = {
            icon = ./icons/streamos/transparent/w95-misc-next.png;
            switch_page = 3;
          };

          "1" = {
            icon = ./icons/streamos/classic-2/w95-mic-off.png;
            command = "xdotool key shift+super+k";
          };
          "10" = {
            icon = ./icons/streamos/classic/w95-discord.png;
            command = "xdotool key shift+super+s";
          };
        };

        "3".buttons = {
          "0" = {
            icon = ./icons/streamos/transparent/w95-misc-previous.png;
            switch_page = 2;
          };
          "2" = {
            icon = ./icons/streamos/transparent/w95-discord.png;
            switch_page = 0;
          };
          "4" = {
            icon = ./icons/streamos/transparent/w95-misc-next.png;
            switch_page = 7;
          };

          "1" = {
            icon = ./icons/streamos/classic-2/w95-mic-off.png;
            command = "xdotool key shift+super+k";
          };

          "5" = {
            icon = ./icons/streamos/classic/w95-off.png;
            command = "xdotool key shift+super+d";
          };
          "6" = {
            icon = ./icons/streamos/classic/w95-mic-off.png;
            command = "xdotool key shift+super+m";
          };

          "8" = {
            icon = ./icons/streamos/vapor/w95-mic-off.png;
            command = "xdotool key shift+super+n";
          };
          "9" = {
            icon = ./icons/streamos/vapor/w95-off.png;
            command = "xdotool key shift+super+f";
          };
        };

        "7".buttons = {
          "0" = {
            icon = ./icons/streamos/transparent/w95-misc-previous.png;
            switch_page = 3;
          };
          "2" = {
            icon = ./icons/streamos/transparent/w95-adobe-photoshop.png;
            switch_page = 0;
          };
        };
      };
  };
}
