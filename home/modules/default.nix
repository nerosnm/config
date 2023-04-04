{
  imports = [
    # Import all the modules, so they can all be imported easily at once
    # elsewhere.
    ./auth.nix
    ./git.nix
    ./irc.nix
    ./nvim
  ];
}
