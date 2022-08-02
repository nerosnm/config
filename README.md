# Nix Configuration

This repository is home to the nix code that builds my systems.

## Why Nix?

Nix allows for easy to manage, collaborative, reproducible deployments. This 
means that once something is setup and configured once, it works forever. If 
someone else shares their configuration, anyone can make use of it.

This flake is configured with the use of [digga][digga].

## How?

To build and apply the configuration immediately:

```console
$ nixos-rebuild --use-remote-sudo switch -p $(hostname) --flake github:nerosnm/config/main
```

To build the configuration and make it available as the most recent generation 
on the next boot:

```console
$ nixos-rebuild --use-remote-sudo boot -p $(hostname) --flake github:nerosnm/config/main
```

[digga]: https://github.com/divnix/digga
