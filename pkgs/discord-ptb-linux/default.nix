{ sources, discord-ptb }:

discord-ptb.overrideAttrs (_: {
  inherit (sources.discord-ptb-linux) pname version src;
})
