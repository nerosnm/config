{
  config,
  lib,
  pkgsUnstable,
  ...
}:
let
  cfg = config.custom.beancount;
in
{
  options.custom.beancount = with lib; {
    enable = mkEnableOption "beancount and fava";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgsUnstable.python314Packages; [
      beancount
      beangulp
      beanquery
      fava
    ];

    launchd.agents.fava = {
      enable = true;
      config = {
        Program = "${pkgsUnstable.python314Packages.fava}/bin/fava";
        ProgramArguments = [
          "${config.home.homeDirectory}/Documents/Financial/Accounts/accounts.beancount"
        ];
        KeepAlive = true;
        RunAtLoad = true;
        ProcessType = "Interactive";
      };
    };
  };
}
