with (import ./. {});
shell {
  toolchains = [
    "arm-zephyr-eabi"
  ];
}
