{ self
, pkgs
, ...
}:

{
  imports = [ ./common.nix ];

  environment.systemPackages =
    let
      extensions = (with pkgs.vscode-extensions; [
        github.github-vscode-theme
        matklad.rust-analyzer
        ms-vsliveshare.vsliveshare
        vscodevim.vim
      ]) ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
        name = "vscode-direnv";
        publisher = "cab404";
        version = "1.0.0";
        sha256 = "sha256-+nLH+T9v6TQCqKZw6HPN/ZevQ65FVm2SAo2V9RecM3Y=";
      }];

      vscode-with-extensions = pkgs.vscode-with-extensions.override {
        vscodeExtensions = extensions;
      };
    in
    with pkgs; [
      aseprite-unfree
      insomnia
      jetbrains.idea-ultimate
      vscode-with-extensions
    ];
}
