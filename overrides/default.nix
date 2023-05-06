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

  iosevka-custom = prev.iosevka.override {
    set = "custom";
    privateBuildPlan = ''
      [buildPlans.iosevka-custom]
      family = "Iosevka"
      spacing = "normal"
      serifs = "sans"
      no-cv-ss = true

      [buildPlans.iosevka-custom.variants]
      inherits = "ss15"

      [buildPlans.iosevka-custom.design]
      digit-form = "old-style"

      [buildPlans.iosevka-custom.ligations]
      enables = [
          "center-ops",
          "arrow",
          "arrow2",
          "trig",
          "eqeqeq",
          "eqeq",
          "ineq",
          "exeqeq-dotted",
          "exeq-dotted",
          "slasheq",
          "ltgt-diamond",
          "plusplus",
          "kern-dotty",
          "kern-bars",
          "logic",
          "llggeq",
          "dot-as-operator",
          "html-comment",
          "connected-number-sign",
          "connected-tilde-as-wave",
      ]
      disables = [
          "exeqeq",
          "eqexeq",
          "eqexeq-dotted",
          "eqexeq-dl",
          "eqexeq-dl-dotted",
          "exeq",
          "tildeeq",
          "eqslasheq",
          "ltgt-ne",
          "brst",
          "llgg",
          "bar-triggers-op-centering",
          "lteq-as-arrow",
          "gteq-as-co-arrow",
          "colon-greater-as-colon-arrow",
          "brace-bar",
          "brack-bar",
          "connected-underscore",
          "connected-hyphen-as-solid-line",
          "connected-hyphen-as-semi-dashed-line",
      ]
    '';
  };
}
