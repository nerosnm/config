{ sources
, tree-sitter-grammars
}:

tree-sitter-grammars.tree-sitter-rust.overrideAttrs (_: {
  inherit (sources.tree-sitter-rust) version src;
})
