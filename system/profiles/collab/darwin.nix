{ pkgs
, ...
}:

{
  homebrew.casks = [
    # "slack" # installed automatically by Pixel
    # "zoom" # installed automatically by Pixel
    "loom"
    "notion"
    "zulip"
  ];
}
