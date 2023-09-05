with (import ./. {});
shell {
  toolchains = [
    "x86_64-zephyr-elf"
  ];
}
