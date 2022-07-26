{ self
, pkgs
, ...
}:

let
  checkBrew = "command -v brew > /dev/null";
  installBrew = ''
    ${pkgs.bash}/bin/bash -c "$(${pkgs.curl}/bin/curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"'';
in
{
  environment = {
    extraInit = ''
      # install homebrew
      ${checkBrew} || ${installBrew}
    '';
  };

  homebrew = {
    enable = true;
    autoUpdate = true;

    global = {
      brewfile = true;
      noLock = true;
    };

    taps = [
      "homebrew/cask"
      "homebrew/cask-drivers"
      "homebrew/core"
      "homebrew/services"
    ];
  };

  fonts.enableFontDir = true;
}
