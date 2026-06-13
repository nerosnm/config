{ lib, pkgsUnstable, ... }: {
  age.identityPaths = [
  ];

  catppuccin.halloy.enable = true;

  home.packages = with pkgsUnstable; [
    catgirl
    convco
    exercism
    ghostscript
    go
    gopls
    jujutsu
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
  ];
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
