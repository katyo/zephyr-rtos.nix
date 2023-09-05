with (import ./. {});
shell {
  toolchains = [
    "arm-zephyr-eabi"
    "x86_64-zephyr-elf"
  ];
  inputs = with pkgs; [
    uncrustify_0_72
    renode
    linuxKernel.packages.linux_6_1.usbip
  ];
}
