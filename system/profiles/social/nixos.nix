{ pkgs
, ...
}:

{
  imports = [ ./common.nix ];

  # Not all of these are strictly "social", but the distinction here is that 
  # these are communication apps that are used at least partly for personal 
  # communication. This is opposed to the apps in the `collab` profile, which 
  # are communication apps used at least partly for work communication.
  environment.systemPackages = with pkgs; [
    discord
    discord-ptb
    signal-desktop
    tiny
    thunderbird
    zulip

    (pkgs.runCommand "catgirl" { buildInputs = [ pkgs.makeWrapper ]; } ''
      mkdir $out
      ln -s ${pkgs.catgirl}/* $out
      rm $out/bin
      mkdir $out/bin
      ln -s ${pkgs.catgirl}/bin/* $out/bin
      rm $out/bin/catgirl
      makeWrapper ${pkgs.catgirl}/bin/catgirl $out/bin/catgirl \
        --set TERM wezterm
    '')
  ];
}
