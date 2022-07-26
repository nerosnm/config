{ sources, polymc }:

polymc.overrideAttrs (_: {
  inherit (sources.polymc) pname version src;
})
