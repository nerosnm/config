{
  description = "A highly structured configuration database.";

  nixConfig.extra-experimental-features = "nix-command flakes";
  nixConfig.extra-substituters = "https://nrdxp.cachix.org https://nix-community.cachix.org";
  nixConfig.extra-trusted-public-keys = "nrdxp.cachix.org-1:Fc5PSqY2Jm1TrWfm88l6cvGWwz3s93c6IOifQWnhNW4= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";

  inputs = {
    # Track channels with commits tested and built by hydra
    nixos.url = "github:nixos/nixpkgs/nixos-22.05";
    latest.url = "github:nixos/nixpkgs/nixos-unstable";
    # For darwin hosts: it can be helpful to track this darwin-specific stable
    # channel equivalent to the `nixos-*` channels for NixOS. For one, these
    # channels are more likely to provide cached binaries for darwin systems.
    # But, perhaps even more usefully, it provides a place for adding
    # darwin-specific overlays and packages which could otherwise cause build
    # failures on Linux systems.
    nixpkgs-darwin-stable.url = "github:NixOS/nixpkgs/nixpkgs-22.05-darwin";

    digga.url = "github:divnix/digga";
    digga.inputs.nixpkgs.follows = "nixos";
    digga.inputs.nixlib.follows = "nixos";
    digga.inputs.home-manager.follows = "home";
    digga.inputs.deploy.follows = "deploy";

    home.url = "github:nix-community/home-manager/master";
    home.inputs.nixpkgs.follows = "latest";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-darwin-stable";

    deploy.url = "github:serokell/deploy-rs";
    deploy.inputs.nixpkgs.follows = "nixos";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixos";

    nvfetcher.url = "github:berberman/nvfetcher";
    nvfetcher.inputs.nixpkgs.follows = "nixos";

    naersk.url = "github:nmattia/naersk";
    naersk.inputs.nixpkgs.follows = "nixos";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    nixos-generators.url = "github:nix-community/nixos-generators";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "latest";
  };

  outputs =
    { self
    , digga
    , nixos
    , home
    , nixos-hardware
    , nur
    , agenix
    , nvfetcher
    , deploy
    , nixpkgs
    , rust-overlay
    , ...
    } @ inputs:
    digga.lib.mkFlake {
      inherit self;

      # If rust-overlay isn't removed from the attrset `inputs` passed to 
      # mkFlake, digga tries to access its `.overlay` output automatically, 
      # which causes a deprecation warning.
      inputs = nixos.lib.attrsets.filterAttrs
        (name: _: name != "rust-overlay")
        inputs;

      channelsConfig = { allowUnfree = true; };

      channels = {
        nixos = {
          imports = [ (digga.lib.importOverlays ./overlays) ];
          overlays = [ ];
        };
        nixpkgs-darwin-stable = {
          imports = [ (digga.lib.importOverlays ./overlays) ];
          overlays = [ ];
        };
        latest = { };
      };

      lib = import ./lib { lib = digga.lib // nixos.lib; };

      sharedOverlays = [
        (final: prev: {
          __dontExport = true;
          lib = prev.lib.extend (lfinal: lprev: {
            our = self.lib;
          });
        })

        nur.overlay
        agenix.overlay
        nvfetcher.overlay
        rust-overlay.overlays.default

        (import ./pkgs)
      ];

      nixos = {
        hostDefaults = {
          system = "x86_64-linux";
          channelName = "latest";
          imports = [ (digga.lib.importExportableModules ./modules) ];
          modules = [
            { lib.our = self.lib; }
            digga.nixosModules.bootstrapIso
            digga.nixosModules.nixConfig
            home.nixosModules.home-manager
            agenix.nixosModules.age
          ];
        };

        imports = [ (digga.lib.importHosts ./hosts/nixos) ];
        hosts = {
          /* set host-specific properties here */
          talitha = { };
          dalim = { };
        };
        importables = rec {
          profiles = digga.lib.rakeLeaves ./profiles // {
            users = digga.lib.rakeLeaves ./users;
          };
          suites = with profiles; rec {
            base = [
              core.nixos

              auth.nixos
              dev.nixos
              gnome
              utility.nixos

              users.root
              users.soren.nixos
            ];
            home = base ++ [
              gaming.nixos
              photo.nixos
              social.nixos
            ];
            work = base ++ [
              collab.nixos
            ];
          };
        };
      };

      darwin = {
        hostDefaults = {
          system = "x86_64-darwin";
          channelName = "nixpkgs-darwin-stable";
          imports = [ (digga.lib.importExportableModules ./modules) ];
          modules = [
            { lib.our = self.lib; }
            digga.darwinModules.nixConfig
            home.darwinModules.home-manager
            agenix.nixosModules.age
          ];
        };

        imports = [ (digga.lib.importHosts ./hosts/darwin) ];
        hosts = {
          /* set host-specific properties here */
          Rigel = { };
          Diadem = { };
        };
        importables = rec {
          profiles = digga.lib.rakeLeaves ./profiles // {
            users = digga.lib.rakeLeaves ./users;
          };
          suites = with profiles; rec {
            base = [
              core.darwin

              auth.darwin
              dev.darwin
              homebrew
              utility.darwin

              users.soren.darwin
            ];
            home = base ++ [
              gaming.darwin
              social.darwin
            ];
            work = base ++ [
              collab.darwin
            ];
          };
        };
      };

      home = {
        imports = [ (digga.lib.importExportableModules ./users/modules) ];
        modules = [ ];
        importables = rec {
          profiles = digga.lib.rakeLeaves ./users/profiles;
          suites = with profiles; rec {
            base = [ ];
          };
        };
        users = {
          soren = { suites, ... }: {
            imports = suites.base;

            home = {
              stateVersion = "20.09";

              sessionPath = [
                "$HOME/.cargo/bin"
              ];

              file.".ssh/id_ed25519_sk.pub".source = ./keys/soren.pub;

              file.".cargo/cargo-generate.toml".text = ''
                [favorites.rust-nix]
                description = "Rust project template with optional Nix flake support"
                git = "https://github.com/nerosnm/rust-nix-template"
              '';
            };

            custom = {
              auth.publicKeys = [
                { host = "*"; path = ./keys/soren.pub; }
              ];
              auth.allowedSigners = [
                { email = "soren@neros.dev"; key = (builtins.readFile ./keys/soren.pub); }
              ];

              dconf = {
                enable = true;
                background = ./assets/misael-moreno-ttLeeAdG-gE-unsplash.jpg;

                # Two sources: UK English and Danish.
                xkbSources = [ "gb" "dk" ];
              };

              git = {
                enable = true;

                user = {
                  name = "Søren Mortensen";
                  email = "soren@neros.dev";
                  key = ./keys/soren.pub;
                };
              };

              irc = {
                enable = true;
                servers = {
                  defaults = {
                    nick = "nerosnm";
                    real = "søren";
                  };

                  libera = {
                    host = "irc.eu.libera.chat";
                    cert = "/run/agenix/soren-libera-cert";
                    join = [ "##rust" "#nixos" "#latex" "#coffee" "#lobsters" "#datahoarder" ];
                  };
                };
              };
            };
          };
        };
      };

      devshell = ./shell;

      homeConfigurations = digga.lib.mergeAny
        (digga.lib.mkHomeConfigurations self.darwinConfigurations)
        (digga.lib.mkHomeConfigurations self.nixosConfigurations)
      ;

      deploy.nodes = digga.lib.mkDeployNodes self.nixosConfigurations { };
    };
}
