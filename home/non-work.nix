{ lib, pkgs, pkgsUnstable, ... }: {
  age.identityPaths = [
  ];

  catppuccin.halloy.enable = true;

  home.packages =
    with pkgs;
    [
      catgirl
      convco
      exercism
      ghostscript
      go
      gopls
      pandoc
      # pdfpc
      # polylux2pdfpc
      # rust-analyzer
      rustup
      tailscale
      tectonic
      thunderbird-bin
      uv
      zmk-studio
    ]
    ++ (with pkgsUnstable; [
      jujutsu
    ]);

  home.username = "maddie";

  programs.halloy = {
    enable = true;
    package = pkgsUnstable.halloy;
    settings = lib.mkForce { };
  };

  custom.nixvim = {
    beancount = true;
    latex = true;
    remote = false;
    swift = true;
    extras = true;
  };

  custom.zed.enable = true;

  xdg.configFile."jj/conf.d/30-non-work.toml".text = "";
}
