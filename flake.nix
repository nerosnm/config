{
  description = "Configuration flake";

  nixConfig.extra-experimental-features = "nix-command flakes";
  nixConfig.extra-substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
    "https://nerosnm.cachix.org"
  ];
  nixConfig.extra-trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "nerosnm.cachix.org-1:y72US4O6QNV8WoofFIOKRL1fnvzd/8IY4OO9a7K4bV8="
  ];

  inputs = {
    # This is the release branch for NixOS 22.11, which is best to use for
    # system configurations for NixOS machines.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";

    # This branch of nixpkgs has newer versions of packages than `nixos-22.11`,
    # but is less likely to have cached binaries than other branches.
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # Absolute bleeding edge version of nixpkgs, not tested or cached yet.
    nixpkgs-master.url = "github:nixos/nixpkgs/master";

    # Fix for iosevka build failures due to Node.js issues.
    nixpkgs-iosevka-fix.url = "github:NixOS/nixpkgs/refs/pull/262124/head";

    # This branch of nixpkgs is more likely than `nixos-22.11` to have cached
    # binaries for Darwin platforms.
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-22.11-darwin";

    # Utility functions for writing flakes.
    flake-utils.url = "github:numtide/flake-utils/main";

    # Enables management of home directory files using Nix.
    home-manager.url = "github:nix-community/home-manager/release-22.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Enables system-level configuration on Darwin platforms.
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    # Secrets management that avoids putting unencrypted secrets in the Nix
    # store.
    agenix.url = "github:ryantm/agenix/main";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    agenix.inputs.darwin.follows = "nixpkgs-darwin";

    # Deploy tool for NixOS servers.
    deploy-rs.url = "github:serokell/deploy-rs/master";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs-unstable";
    deploy-rs.inputs.utils.follows = "flake-utils";

    cargo2nix.url = "github:cargo2nix/cargo2nix";
    cargo2nix.inputs.flake-utils.follows = "flake-utils";
    cargo2nix.inputs.nixpkgs.follows = "nixpkgs-unstable";

    fenix.url = "github:nix-community/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs-unstable";

    cacti-dev.url = "github:nerosnm/cacti.dev/main";
    cacti-dev.inputs.nixpkgs.follows = "nixpkgs";
    cacti-dev.inputs.flake-utils.follows = "flake-utils";

    neros-dev.url = "git+ssh://git@github.neros.dev/nerosnm/neros.dev.git?ref=new-observability";
    neros-dev.inputs.cargo2nix.follows = "cargo2nix";
    neros-dev.inputs.fenix.follows = "fenix";
    neros-dev.inputs.flake-utils.follows = "flake-utils";
    neros-dev.inputs.nixpkgs.follows = "nixpkgs";

    hatysa.url = "github:nerosnm/hatysa/master";
    hatysa.inputs.cargo2nix.follows = "cargo2nix";
    hatysa.inputs.fenix.follows = "fenix";
    hatysa.inputs.flake-utils.follows = "flake-utils";
    hatysa.inputs.nixpkgs.follows = "nixpkgs";

    oxbow.url = "github:nerosnm/oxbow/main";
    oxbow.inputs.cargo2nix.follows = "cargo2nix";
    oxbow.inputs.fenix.follows = "fenix";
    oxbow.inputs.flake-utils.follows = "flake-utils";
    oxbow.inputs.nixpkgs.follows = "nixpkgs";

    pomocop.url = "github:nerosnm/pomocop/main";
    pomocop.inputs.cargo2nix.follows = "cargo2nix";
    pomocop.inputs.fenix.follows = "fenix";
    pomocop.inputs.flake-utils.follows = "flake-utils";
    pomocop.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-darwin
    , nixpkgs-unstable
    , nixpkgs-master
    , flake-utils
    , nix-darwin
    , ...
    } @ inputs:
    let
      inherit (nixpkgs.lib) attrValues getAttrs hasSuffix mapAttrs;
      inherit (flake-utils.lib) eachSystem;

      systems = flake-utils.lib.system;

      # The list of overlays that should be applied (first) to every import of
      # nixpkgs, regardless of which channel is being imported.
      baseOverlays = system: [
        (final: prev: {
          cacti-dev = inputs.cacti-dev.defaultPackage.${system};
          hatysa = inputs.hatysa.packages.${system}.default;
          neros-dev = inputs.neros-dev.packages.${system}.neros-dev;
          neros-dev-content = inputs.neros-dev.packages.${system}.content;
          neros-dev-static = inputs.neros-dev.packages.${system}.static;
          neros-dev-stylesheet = inputs.neros-dev.packages.${system}.stylesheet;
          oxbow = inputs.oxbow.packages.${system}.default;
          oxbow-cacti-dev = inputs.oxbow.packages.${system}.oxbow-cacti-dev;
          pomocop = inputs.pomocop.packages.${system}.default;
        })
      ] ++ map (input: input.overlays.default) (with inputs; [
        agenix
      ]);

      # An overlay that overrides existing package definitions, such as by
      # customising the arguments passed to them.
      overrides = (import ./overrides);

      # An overlay that introduces local custom packages.
      customPkgs = (import ./pkgs);

      # A function that imports the given `channel` (which should be a branch of
      # nixpkgs in the form of an input to this flake, like `nixpkgs` or
      # `nixpkgs-unstable`) for the system `system`, setting any necessary
      # config and applying the `upgradeOverlays` in the correct position
      # between the `baseOverlays` and the customisation overlays (`customPkgs`
      # and `overrides`).
      #
      # "Correct position" here refers to the convention I've decided on for
      # overlay order in this flake: overlays should be applied in increasing
      # order of how much local control they exert over the package definitions.
      #
      # In other words:
      #
      # - Overlays defined in inputs are applied first because we have no
      #   control whatsoever over what the overlay does (and we would normally
      #   not want to mess with their inputs by applying other overlays before
      #   them).
      # - Then "upgrade overlays" should be applied, because they normally only
      #   pull packages from newer channels of nixpkgs, and don't do anything
      #   more, such as modifying the package definitions themselves. These
      #   should be applied in increasing order of how up-to-date the channel is
      #   that they pull packages from.
      # - Then overrides should be applied, because they modify package
      #   definitions by overriding their inputs or attributes.
      # - Finally, the custom packages overlay should be applied, because custom
      #   packages *completely replace* previous package definitions.
      #
      # This allows for some cool things, like upgrading the version of a
      # package first and then overriding its arguments separately later,
      # regardless of which version is being overridden.
      pkgsFor =
        { channel
        , system
        , upgradeOverlays ? [ ]
        }: import channel {
          inherit system;
          config.allowUnfree = true;
          overlays = (baseOverlays system) ++ upgradeOverlays ++ [ overrides customPkgs ];
        };

      # An overlay that picks packages from the flake inputs, regardless of the
      # channel this overlay is being applied to. This will be applied to all
      # channels, so that specific packages can be added or replaced with ones
      # from the flake inputs.
      upgradeToFromInput = system: _: _: nixpkgs.lib.genAttrs
        [
          "agenix"
          "deploy-rs"
          "home-manager"
        ]
        (name: inputs."${name}".packages."${system}".default);

      upgradeToCustomChannels = system: final: prev:
        let
          nodejsPath = inputs.nixpkgs-iosevka-fix + "/pkgs/development/web/nodejs";
          nodeVersion = x: final.callPackage (nodejsPath + "/v${x}.nix");
          v14 = nodeVersion "14";
          v16 = nodeVersion "16";
          v18 = nodeVersion "18";
          v20 = nodeVersion "20";
        in
        {
          nodejs_14 = v14 { openssl = final.openssl_1_1; };
          nodejs-slim_14 = v14 { enableNpm = false; openssl = final.openssl_1_1; };
          nodejs_16 = v16 { };
          nodejs-slim_16 = v16 { enableNpm = false; };
          nodejs_18 = v18 { };
          nodejs-slim_18 = v18 { enableNpm = false; };
          nodejs_20 = v20 { };
          nodejs-slim_20 = v20 { enableNpm = false; };
        };

      # A function that imports `nixpkgs-master` for the given system, with all
      # relevant upgrade overlays applied. In the case of `nixpkgs-master`, the
      # only relevant upgrade overlay is the `upgradeToFromInput` overlay, to
      # take packages directly from the flake inputs (any other upgrade overlays
      # would either cause infinite recursion or represent a *downgrade*
      # instead).
      masterFor = system: pkgsFor {
        channel = nixpkgs-master;
        inherit system;
        upgradeOverlays = [
          (upgradeToCustomChannels system)
          (upgradeToFromInput system)
        ];
      };

      # An overlay that picks packages from `master`, regardless of the channel
      # this overlay is being applied to. This will be applied to all channels
      # with packages older than the ones in `nixpkgs-master`, so that specific
      # packages can be upgraded to ones from master.
      upgradeToMaster = master: _: _: {
        inherit (master)
          iosevka
          prismlauncher
          rust-analyzer-unwrapped
          wezterm
          ;
      };

      # A function that imports `nixpkgs-unstable` for the given system, with
      # all relevant upgrade overlays applied. In the case of
      # `nixpkgs-unstable`, the relevant upgrade overlays are
      # `upgradeWithMaster` (to upgrade any packages that are too old on
      # unstable to the ones from master), and `upgradeToFromInputs`.
      unstableFor = system: pkgsFor {
        channel = nixpkgs-unstable;
        inherit system;
        upgradeOverlays = [
          (upgradeToMaster (masterFor system))
          (upgradeToCustomChannels system)
          (upgradeToFromInput system)
        ];
      };

      # An overlay that picks packages from `unstable`, regardless of the
      # channel this overlay is being applied to. This will be applied to all
      # channels with packages older than the ones in `nixpkgs-unstable`, so
      # that specific packages can be upgraded to ones from unstable.
      upgradeToUnstable = unstable: _: _: {
        inherit (unstable)
          age-plugin-yubikey
          bat
          # cachix
          cargo-about
          cargo-deny
          cargo-expand
          cargo-generate
          cargo-modules
          cargo-update
          cargo-watch
          erdtree
          fd
          git
          git-lfs
          gnome-photos
          grafana
          keybase
          nixpkgs-fmt
          openssh
          pounce
          rage
          rustup
          starship
          streamdeck-ui
          tailscale
          tectonic
          tempo
          tlaplus18
          udisks
          yubikey-manager
          ;

        inherit (unstable.vimPlugins)
          nvim-treesitter-parsers;
      };

      # If we're using Darwin, we should use the Darwin-specific version of
      # nixpkgs. Otherwise, use the release branch.
      selectStable = system:
        if (hasSuffix "-darwin" system)
        then nixpkgs-darwin
        else nixpkgs;

      # A function that imports the most relevant stable channel of nixpkgs for
      # the given system, with all relevant upgrade overlays applied. For stable
      # channels, the relevant upgrade overlays are `upgradeWithUnstable` (to
      # upgrade any packages that are too old on stable to the ones from
      # unstable), `upgradeWithMaster` and `upgradeToFromInput`.
      stableFor = system: pkgsFor {
        channel = (selectStable system);
        inherit system;
        upgradeOverlays = [
          (upgradeToUnstable (unstableFor system))
          (upgradeToMaster (masterFor system))
          (upgradeToCustomChannels system)
          (upgradeToFromInput system)
        ];
      };

      supportedSystems = with systems; [
        aarch64-darwin
        x86_64-darwin
        x86_64-linux
      ];
    in
    (eachSystem supportedSystems (system:
    let
      # By using the "stable" packages for the base packages of everything,
      # including the devShell, the versions of packages will be consistent
      # across all contexts in this flake. For example, a package that is
      # upgraded to an unstable version by an overlay will appear as the
      # unstable version both in the devShell and in system configurations. At
      # the same time, the maximum number of cached versions of packages will be
      # used.
      pkgs = stableFor system;
    in
    {
      packages = {
        inherit (pkgs)
          carbon-now-nvim
          cmp-fuzzy-path
          fuzzy-nvim
          git-blame-nvim
          iosevka-custom
          key-menu-nvim
          pest-vim
          rust-tools-nvim
          rust-vim
          telescope-file-browser-nvim
          tla-nvim
          ;
        neovim = self.legacyPackages.${system}.homeConfigurations.soren.config.programs.neovim.finalPackage;
      };

      legacyPackages = {
        homeConfigurations = {
          soren = inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ./home
              ./home/users/soren.nix
            ];
          };
        };
      };

      devShells = {
        default = pkgs.mkShell {
          name = "nerosnm/config";
          packages = with pkgs; [
            age-plugin-yubikey
            agenix
            deploy-rs
            home-manager
          ];
        };
      };

      formatter = pkgs.nixpkgs-fmt;
    })) // {
      nixosConfigurations = {
        atria =
          let
            system = systems.x86_64-linux;
            pkgs = stableFor system;
          in
          nixpkgs.lib.nixosSystem {
            inherit system pkgs;
            modules = [
              inputs.agenix.nixosModules.age
              ./system/hosts/atria.nix
            ] ++ (pkgs.lib.attrValues self.nixosModules);
          };

        stribor =
          let
            system = systems.x86_64-linux;
            pkgs = stableFor system;
          in
          nixpkgs.lib.nixosSystem {
            inherit system pkgs;
            modules = [
              inputs.agenix.nixosModules.age
              ./system/hosts/stribor.nix
            ] ++ (pkgs.lib.attrValues self.nixosModules);
          };
      };

      darwinConfigurations = {
        nashira =
          let
            system = systems.aarch64-darwin;
            pkgs = stableFor system;
          in
          nix-darwin.lib.darwinSystem {
            inherit system pkgs;
            modules = [
              inputs.agenix.darwinModules.age
              ./system/hosts/nashira.nix
            ];
          };
      };

      nixosModules = {
        cacti-dev = import ./system/modules/cacti-dev.nix;
        grafana = import ./system/modules/grafana.nix;
        hatysa = import ./system/modules/hatysa.nix;
        ll5 = import ./system/modules/ll5.nix;
        loki = import ./system/modules/loki.nix;
        neros-dev = import ./system/modules/neros-dev.nix;
        oxbow = import ./system/modules/oxbow.nix;
        pomocop = import ./system/modules/pomocop.nix;
        prometheus = import ./system/modules/prometheus.nix;
        tailscale = import ./system/modules/tailscale.nix;
        tempo = import ./system/modules/tempo.nix;
      };

      overlays = {
        inherit customPkgs overrides;
      };

      deploy = {
        sshUser = "root";
        autoRollback = true;
        magicRollback = true;

        nodes = {
          atria =
            let
              deployLib = inputs.deploy-rs.lib.x86_64-linux;
            in
            {
              hostname = "atria";

              profiles = {
                system = {
                  user = "root";
                  path = deployLib.activate.nixos self.nixosConfigurations.atria;
                };
              };
            };

          stribor =
            let
              deployLib = inputs.deploy-rs.lib.x86_64-linux;
            in
            {
              hostname = "stribor";

              profiles = {
                system = {
                  user = "root";
                  path = deployLib.activate.nixos self.nixosConfigurations.stribor;
                };
              };
            };
        };
      };
    };
}
