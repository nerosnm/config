{ self
, config
, lib
, pkgs
, ...
}:

with lib;
let
  cfg = config.custom.misc;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  inherit (lib) mkMerge;
in
{
  options.custom.misc = with types; {
    wezterm = {
      colorScheme = mkOption {
        description = "WezTerm color scheme";
        type = str;
        default = "OneHalfDark";
      };
    };
  };

  config = mkMerge [
    {
      home.file.".indentconfig.yaml".text = ''
        paths:
        - ${config.home.homeDirectory}/.indentsettings.yaml
      '';

      home.file.".indentsettings.yaml".text = ''
        defaultIndent: "  "
        verbatimEnvironments:
          listing: 1
          lstlisting: 1
          minted: 1
          tikzpicture: 1
          verbatim: 1
      '';

      xdg.configFile."wireplumber/main.lua.d/51-ga104-disable.lua".text = ''
        rule = {
          matches = {
            {
              { "device.name", "equals", "alsa_card.pci-0000_2b_00.1" }
            },
          },
          apply_properties = {
            ["device.disabled"] = true,
          },
        }

        table.insert(alsa_monitor.rules,rule)
      '';

      xdg.configFile."wireplumber/main.lua.d/51-kanto-yu2-rename.lua".text = ''
        rule = {
          matches = {
            {
              { "device.name", "equals", "alsa_card.usb-Burr-Brown_from_TI_USB_Audio_DAC-00" }
            },
          },
          apply_properties = {
            ["device.description"] = "Kanto Yu2",
          },
        }

        table.insert(alsa_monitor.rules,rule)
      '';

      xdg.configFile."wireplumber/main.lua.d/51-scarlett-solo-rename.lua".text = ''
        rule = {
          matches = {
            {
              { "device.name", "equals", "alsa_card.usb-Focusrite_Scarlett_Solo_USB-00" }
            },
          },
          apply_properties = {
            ["device.description"] = "Scarlett Solo",
          },
        }

        table.insert(alsa_monitor.rules,rule)
      '';

      xdg.configFile."nvim/syntax/marsh.vim".source = ./marsh.vim;

      xdg.configFile."helix/config.toml".text = ''
        theme = "onedark"

        [editor]
        line-number = "relative"
        true-color = true
        auto-pairs = false
        cursor-shape = { insert = "bar", normal = "block", select = "block" }

        [lsp]
        display-messages = true
      '';

      xdg.configFile."wezterm/wezterm.lua".text = ''
        local wezterm = require 'wezterm';

        local mykeys = {
          -- Reload the config file
          { key = "r", mods = "LEADER", action = "ReloadConfiguration" },

          -- Enter and exit fullscreen
          { key = "Enter", mods = "ALT", action = "ToggleFullScreen" },

          -- Create and close tabs
          { key = "c", mods = "LEADER", action = wezterm.action { SpawnCommandInNewTab = { domain = "CurrentPaneDomain", cwd = "~" } } },
          { key = "k", mods = "LEADER", action = wezterm.action { CloseCurrentTab = { confirm = true } } },

          -- Select next and previous tabs
          { key = "n", mods = "LEADER", action = wezterm.action { ActivateTabRelative = 1 } },
          { key = "p", mods = "LEADER", action = wezterm.action { ActivateTabRelative = -1 } },

          -- Create horizontal or vertical splits (close by sending EOF with Ctrl-D)
          { key = "|", mods = "LEADER", action = wezterm.action { SplitHorizontal = { domain = "CurrentPaneDomain" } } },
          { key = "|", mods = "LEADER|SHIFT", action = wezterm.action { SplitHorizontal = { domain = "CurrentPaneDomain" } } },
          { key = "-", mods = "LEADER", action = wezterm.action { SplitVertical = { domain = "CurrentPaneDomain" } } },

          -- Move between splits
          { key = "h", mods = "SUPER", action = wezterm.action { ActivatePaneDirection = "Left" } },
          { key = "j", mods = "SUPER", action = wezterm.action { ActivatePaneDirection = "Down" } },
          { key = "k", mods = "SUPER", action = wezterm.action { ActivatePaneDirection = "Up" } },
          { key = "l", mods = "SUPER", action = wezterm.action { ActivatePaneDirection = "Right" } },

          -- Copy and paste text
          { key = "c", mods = "SUPER", action = "Copy" },
          { key = "v", mods = "SUPER", action = "Paste" },

          -- Zoom in and out
          { key = "-", mods = "CTRL", action = "DecreaseFontSize" },
          { key = "=", mods = "CTRL", action = "IncreaseFontSize" },
          { key = "0", mods = "CTRL", action = "ResetFontSize" },
        }

        -- Insert bindings to select each tab
        for i = 1, 9 do
          table.insert(mykeys, {
            key = tostring(i),
            mods = "LEADER",
            action = wezterm.action { ActivateTab = i - 1 },
          })
        end

        table.insert(mykeys, {
          key = "0",
          mods = "LEADER",
          action = wezterm.action { ActivateTab = 9 },
        })

        wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
          local pane = tab.active_pane
          local cwd = string.match(pane.current_working_dir, "/([^/]+)/$")
          if cwd ~= nil then
            return {
              {Text=" " .. (tab.tab_index + 1) .. ": " .. tab.active_pane.title .. " | " .. cwd .. " "},
            }
          end
          return tab.active_pane.title
        end)

        return {
          color_scheme = "${cfg.wezterm.colorScheme}",
          font = wezterm.font("Iosevka", { weight = "Light", }),
          enable_scroll_bar = true,

          ${optionalString (cfg.wezterm.colorScheme == "OneHalfDark") ''
          -- colors = {
          --   ansi = {
          --     '#383e49',
          --     '#e06c75',
          --     '#98c379',
          --     '#e5c07b',
          --     '#61afef',
          --     '#c678dd',
          --     '#56b6c2',
          --     '#dcdfe4',
          --   },
          -- },
          ''}


          exit_behavior = "Close",

          -- The leader key (Ctrl-Space) must be pressed before any bindings with the LEADER modifier
          leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1000 },

          disable_default_key_bindings = true,
          keys = mykeys,

          warn_about_missing_glyphs = false,

          check_for_updates = false,

          unix_domains = {
            {
              name = "talitha",
              proxy_command = { "ssh", "-T", "-A", "talitha", "wezterm", "cli", "proxy" },
            },
          },

          ${optionalString isDarwin ''
          font_size = 16.0,
          window_decorations = "RESIZE",
          ''}
        }
      '';
    }

    (if (builtins.hasAttr "xdg.mimeApps" options) then {
      xdg.configFile."mimeapps.list".force = true;
      xdg.mimeApps = {
        enable = true;

        defaultApplications = {
          "text/html" = "firefox.desktop";
          "x-scheme-handler/mailto" = "thunderbird.desktop";
          "message/rfc822" = "thunderbird.desktop";
          "image/jpeg" = "org.gnome.eog.desktop";
          "image/bmp" = "org.gnome.eog.desktop";
          "image/gif" = "org.gnome.eog.desktop";
          "image/jpg" = "org.gnome.eog.desktop";
          "image/pjpeg" = "org.gnome.eog.desktop";
          "image/png" = "org.gnome.eog.desktop";
          "image/tiff" = "org.gnome.eog.desktop";
          "image/x-bmp" = "org.gnome.eog.desktop";
          "image/x-gray" = "org.gnome.eog.desktop";
          "image/x-icb" = "org.gnome.eog.desktop";
          "image/x-ico" = "org.gnome.eog.desktop";
          "image/x-png" = "org.gnome.eog.desktop";
          "image/x-portable-anymap" = "org.gnome.eog.desktop";
          "image/x-portable-bitmap" = "org.gnome.eog.desktop";
          "image/x-portable-graymap" = "org.gnome.eog.desktop";
          "image/x-portable-pixmap" = "org.gnome.eog.desktop";
          "image/x-xbitmap" = "org.gnome.eog.desktop";
          "image/x-xpixmap" = "org.gnome.eog.desktop";
          "image/x-pcx" = "org.gnome.eog.desktop";
          "image/svg+xml" = "org.gnome.eog.desktop";
          "image/svg+xml-compressed" = "org.gnome.eog.desktop";
          "image/vnd.wap.wbmp" = "org.gnome.eog.desktop";
          "image/x-icns" = "org.gnome.eog.desktop";
          "x-scheme-handler/msteams" = "teams.desktop";
          "x-scheme-handler/http" = "firefox.desktop";
          "application/xhtml+xml" = "firefox.desktop";
          "x-scheme-handler/https" = "firefox.desktop";
        };

        associations.added = {
          "x-scheme-handler/mailto" = "thunderbird.desktop";
          "message/rfc822" = "thunderbird.desktop";
          "application/pdf" = [ "org.pwmt.zathura-pdf-mupdf.desktop" "org.gnome.Evince.desktop" "firefox.desktop" ];
          "image/png" = [ "gimp.desktop" "firefox.desktop" "feh.desktop" "org.gnome.eog.desktop" ];
          "text/plain" = "firefox.desktop";
          "application/x-mobipocket-ebook" = "calibre-gui.desktop";
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "calibre-ebook-viewer.desktop";
          "image/svg+xml" = [ "firefox.desktop" "org.gnome.eog.desktop" ];
          "image/jpeg" = [ "firefox.desktop" "aseprite.desktop" ];
          "image/bmp" = "org.gnome.eog.desktop";
          "image/gif" = "org.gnome.eog.desktop";
          "image/jpg" = "org.gnome.eog.desktop";
          "image/pjpeg" = "org.gnome.eog.desktop";
          "image/tiff" = "org.gnome.eog.desktop";
          "image/x-bmp" = "org.gnome.eog.desktop";
          "image/x-gray" = "org.gnome.eog.desktop";
          "image/x-icb" = "org.gnome.eog.desktop";
          "image/x-ico" = "org.gnome.eog.desktop";
          "image/x-png" = "org.gnome.eog.desktop";
          "image/x-portable-anymap" = "org.gnome.eog.desktop";
          "image/x-portable-bitmap" = "org.gnome.eog.desktop";
          "image/x-portable-graymap" = "org.gnome.eog.desktop";
          "image/x-portable-pixmap" = "org.gnome.eog.desktop";
          "image/x-xbitmap" = "org.gnome.eog.desktop";
          "image/x-xpixmap" = "org.gnome.eog.desktop";
          "image/x-pcx" = "org.gnome.eog.desktop";
          "image/svg+xml-compressed" = "org.gnome.eog.desktop";
          "image/vnd.wap.wbmp" = "org.gnome.eog.desktop";
          "image/x-icns" = "org.gnome.eog.desktop";
          "image/webp" = [ "aseprite.desktop" "org.gnome.eog.desktop" ];
          "video/mp4" = [ "mpv.desktop" "org.gnome.Totem.desktop" ];
          "text/x-bibtex" = "org.gnome.TextEditor.desktop";
          "text/markdown" = "org.gnome.TextEditor.desktop";
          "application/json" = "org.gnome.TextEditor.desktop";
          "x-scheme-handler/http" = [ "firefox.desktop" "chromium-browser.desktop" ];
          "application/xhtml+xml" = [ "firefox.desktop" "chromium-browser.desktop" ];
          "x-scheme-handler/https" = [ "firefox.desktop" "chromium-browser.desktop" ];
          "text/html" = [ "firefox.desktop" "chromium-browser.desktop" ];
        };
      };
    } else { })
  ];
}
