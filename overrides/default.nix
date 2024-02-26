final: prev: {
  catgirl = prev.catgirl.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./patches/bright.patch
    ];
  });

  tailscale = prev.tailscale.overrideAttrs (old: {
    subPackages = old.subPackages ++ [
      "cmd/proxy-to-grafana"
    ];
  });

  python311 = prev.python311.override {
    packageOverrides = pythonFinal: pythonPrev: {
      build = pythonPrev.build.overrideAttrs (attrs: {
        __darwinAllowLocalNetworking = true;
      });
    };
  };

  iosevka-custom = prev.iosevka.override {
    set = "custom";
    privateBuildPlan = ''
      [buildPlans.iosevka-custom]
      family = "Iosevka Custom"
      spacing = "term"
      serifs = "sans"
      no-cv-ss = true

      [buildPlans.iosevka-custom.variants]
      inherits = "ss15"

      [buildPlans.iosevka-custom.variants.design]
      digit-form = "old-style"
      capital-g = "toothless-corner-inward-serifed-hooked"
      capital-p = "open-serifless"
      capital-q = "open-swash"
      capital-r = "straight-open-serifless"
      capital-v = "curly-serifless"
      capital-w = "curly-serifless"
      capital-x = "curly-serifless"
      capital-y = "curly-serifless"
      capital-z = "curly-serifless"
      i = "serifed-asymmetric"
      q = "tailed-serifless"
      r = "serifed"
      u = "toothed-bottom-right-serifed"
      v = "curly-serifless"
      w = "curly-serifless"
      x = "semi-chancery-curly"
      y = "curly-serifless"
      z = "curly-serifless"
      lower-eth = "straight-bar"
      two = "curly-neck"
      three = "flat-top"
      four = "semi-open-non-crossing"
      seven = "bend-serifed-crossbar"
      underscore = "high"
      guillemet = "curly"
      number-sign = "upright-open"
      ampersand = "flat-top"
      dollar = "interrupted"
      percent = "rings-continuous-slash-also-connected"
      ascii-single-quote = "straight"
      question = "smooth"
      cent = "bar-interrupted"
      lig-ltgteq = "flat"
      lig-neq = "vertical-dotted"
      lig-equal-chain = "without-notch"
      lig-hyphen-chain = "with-notch"

      [buildPlans.iosevka-custom.variants.italic]
      capital-u = "tailed-serifless"
      capital-z = "cursive-with-horizontal-crossbar"
      i = "serifed-diagonal-tailed"
      q = "diagonal-tailed-serifless"
      v = "cursive-serifed"
      w = "cursive-serifless"
      x = "cursive"
      y = "curly-turn-serifless"
      z = "cursive-with-horizontal-crossbar"
      ascii-single-quote = "straight"
      lig-neq = "slightly-slanted-dotted"

      [buildPlans.iosevka-custom.ligations]
      enables = [
        "center-ops",
        "center-op-trigger-plus-minus-r",
        "center-op-trigger-equal-l",
        "center-op-trigger-equal-r",
        "center-op-trigger-bar-l",
        "center-op-trigger-bar-r",
        "center-op-trigger-angle-inside",
        "center-op-trigger-angle-outside",
        "center-op-influence-dot",
        "center-op-influence-colon",
        "arrow-l",
        "arrow-r",
        "counter-arrow-l",
        "counter-arrow-r",
        "trig",
        "eqeqeq",
        "eqeq",
        "lteq",
        "gteq",
        "exeqeqeq",
        "exeqeq",
        "exeq",
        "eqslasheq",
        "slasheq",
        "ltgt-diamond",
        "ltgt-slash-tag",
        "slash-asterisk",
        "plusplus",
        "kern-dotty",
        "kern-bars",
        "logic",
        "llggeq",
        "html-comment",
        "connected-number-sign",
        "connected-tilde-as-wave",
      ]
      disables = [
        "center-op-trigger-plus-minus-l",
        "eqlt",
        "lteq-separate",
        "eqlt-separate",
        "gteq-separate",
        "eqexeq",
        "eqexeq-dl",
        "tildeeq",
        "ltgt-ne",
        "ltgt-diamond-tag",
        "brst",
        "llgg",
        "colon-greater-as-colon-arrow",
        "brace-bar",
        "brack-bar",
        "connected-underscore",
        "connected-hyphen",
      ]

      [buildPlans.iosevka-custom.widths.normal]
      shape = 500
      menu = 5
      css = "normal"
    '';
  };
}
