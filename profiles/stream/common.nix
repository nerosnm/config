{ self
, pkgs
, ...
}:

{
  environment.systemPackages = with pkgs; [
    ffmpeg
  ];
}
