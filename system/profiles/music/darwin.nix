{ config
, pkgs
, ...
}:

# This profile is primarily centered around packages and configuration related
# to the *production* of music, rather than music *listening*. I consider music
# listening to be such a core purpose of a computer that packages and
# configuration for that are usually in base or utility config files.

{
  homebrew.casks = [
    "ableton-live-standard"
    "splice"
  ];
}
