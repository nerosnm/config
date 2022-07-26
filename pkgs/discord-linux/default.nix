{ sources, discord }:

discord.overrideAttrs (_: {
  inherit (sources.discord-linux) pname version src;
})
