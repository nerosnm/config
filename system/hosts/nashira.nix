{ config
, pkgs
, lib
, ...
}:

{
  imports = [
    ../base/darwin.nix

    ../profiles/auth/darwin.nix
    ../profiles/collab/darwin.nix
    ../profiles/dev/darwin.nix
    ../profiles/utility/darwin.nix
  ];

  programs.fish = {
    enable = true;

    loginShellInit =
      let
        # Fix for incorrect order of items in $PATH, from:
        # https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
        #
        # This naive quoting is good enough in this case. There shouldn't be any
        # double quotes in the input string, and it needs to be double quoted in case
        # it contains a space (which is unlikely!)
        dquote = str: "\"" + str + "\"";

        makeBinPathList = map (path: path + "/bin");
      in
      ''
        fish_add_path --move --prepend --path ${lib.concatMapStringsSep " " dquote (makeBinPathList config.environment.profiles)}
        set fish_user_paths $fish_user_paths
      '';
  };

  environment.shells = with pkgs; [
    fish
  ];

  users = {
    # TODO: Figure out if there's a way to default this (in ../base/darwin.nix),
    # rather than setting it for individual users.
    users.soren.shell = pkgs.fish;
  };

  age.secrets.ditto-license = {
    file = ../../secrets/ditto-license.age;
    owner = "soren";
  };
  age.secrets.quay-email-ditto = {
    file = ../../secrets/quay-email-ditto.age;
    owner = "soren";
  };
  age.secrets.quay-token-ditto = {
    file = ../../secrets/quay-token-ditto.age;
    owner = "soren";
  };
  age.secrets.quay-user-ditto = {
    file = ../../secrets/quay-user-ditto.age;
    owner = "soren";
  };
  environment.extraInit = ''
    export DITTO_LICENSE="$(cat ${config.age.secrets.ditto-license.path})"
    export QUAY_EMAIL="$(cat ${config.age.secrets.quay-email-ditto.path})"
    export QUAY_TOKEN="$(cat ${config.age.secrets.quay-token-ditto.path})"
    export QUAY_USER="$(cat ${config.age.secrets.quay-user-ditto.path})"
  '';
}
