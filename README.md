# Nix environment for Zephyr RTOS developers

I using this config for a year.

## Usage

1. Install [nix](https://nixos.org/download.html)
2. Clone this repo
3. Change dir to repo dir and run `nix-shell`

## Config

You can select required toolchains and add extra dependencies
by creating custom derived `shell.nix` (see `shell-*.nix`).

## SDL

Add `SDL2` to `inputs` if you need emulated graphic devices.
