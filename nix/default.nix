{ ... }:
{
  pkgs = import ./packages.nix {};
  shell = import ./shell.nix;
}
