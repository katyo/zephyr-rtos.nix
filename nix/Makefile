versions ?= \
  0.14.0 \
  0.14.2 \
  0.15.0 \
  0.15.2 \
  0.16.0

hosts ?= \
  linux-aarch64 \
  linux-x86_64 \
  macos-x86_64 \
  macos-aarch64 \
  windows-x86_64

toolchains ?= \
  aarch64-zephyr-elf \
  arc64-zephyr-elf \
  arc-zephyr-elf \
  arm-zephyr-eabi \
  mips-zephyr-elf \
  nios2-zephyr-elf \
  riscv64-zephyr-elf \
  sparc-zephyr-elf \
  x86_64-zephyr-elf \
  xtensa-espressif_esp32_zephyr-elf \
  xtensa-espressif_esp32s2_zephyr-elf \
  xtensa-intel_apl_adsp_zephyr-elf \
  xtensa-intel_bdw_adsp_zephyr-elf \
  xtensa-intel_byt_adsp_zephyr-elf \
  xtensa-intel_s1000_zephyr-elf \
  xtensa-nxp_imx_adsp_zephyr-elf \
  xtensa-nxp_imx8m_adsp_zephyr-elf \
  xtensa-sample_controller_zephyr-elf

hashes ?= \
  sha256

exts ?= .tar.xz .tar.gz .7z .zip

# args: version
download_base = https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v$(1)

# args: version, algo (md5|sha256)
hash_url = $(call download_base,$(1))/$(2).sum

# args: version, algo
hash_file = $(1).$(2)

# args: version, algo, file pfx
hash_get = $(shell grep '$(3)[.]' $(call hash_file,$(1),$(2)) | sed -r 's/[[:space:]]+[^[:space:]]+$$//g' | xargs nix --extra-experimental-features nix-command hash to-sri --type sha256)

# args: version, algo, file pfx
file_get = $(shell grep '$(3)[.]' $(call hash_file,$(1),$(2)) | sed -r 's/^[^[:space:]]+[[:space:]]+//g')

# args: host
hosttools_file = hosttools_$(1)

# args: version, host
sdk_full_file = zephyr-sdk-$(1)_$(2)

# args: version, host
sdk_min_file = zephyr-sdk-$(1)_$(2)_minimal

# args: host, toolchain
toolchain_file = toolchain_$(1)_$(2)

# args: func(version, host, toolchain)
foreach_all = $(foreach version,$(versions),$(foreach host,$(hosts),$(foreach toolchain,$(toolchains),$(call $(1),$(version),$(host),$(toolchain)))))

# args: version, algo
define fetch-hash-rules
fetch-hash: fetch-hash-$(1)-$(2)
fetch-hash-$(1)-$(2): $(call hash_file,$(1),$(2))
$(call hash_file,$(1),$(2)):
	@wget -O $$@ $(call hash_url,$(1),$(2))
clean-hash: clean-hash-$(1)-$(2)
clean-hash-$(1)-$(2):
	@rm -f $(call hash_file,$(1),$(2))
endef

clean: clean-hash

$(foreach version,$(versions),$(foreach hash,$(hashes),$(eval $(call fetch-hash-rules,$(version),$(hash)))))

show-toolchain-files:
	@echo $(call foreach_all,toolchain_file)

test: fetch-hash
	@echo $(call hash_get,$(versions),sha256,$(call hosttools_file,linux-aarch64))

# args: ident, pfx, hash, file
define put_hash_out

$(1)$(2) = {
$(1)  file = \"$(4)\";
$(1)  hash = \"$(3)\";
$(1)};
endef

# args: ident, pfx, hash, file
put_hash_cond = $(if $(3),$(call put_hash_out,$(1),$(2),$(3),$(4)))

# args: ident, pfx, version, file pfx
put_hash = $(call put_hash_cond,$(1),$(2),$(call hash_get,$(3),sha256,$(4)),$(call file_get,$(3),sha256,$(4)))

# args: version, host
define gen_host_version_info

    \"$(2)\" = {\
$(call put_hash,      ,hosttools,$(1),$(call hosttools_file,$(2)))\
$(call put_hash,      ,full,$(1),$(call sdk_full_file,$(1),$(2)))\
$(call put_hash,      ,minimal,$(1),$(call sdk_min_file,$(1),$(2)))
      toolchains = {\
$(foreach toolchain,$(toolchains),$(call put_hash,        ,\"$(toolchain)\",$(1),$(call toolchain_file,$(2),$(toolchain))))
      };
    };
endef

# args: version
define gen_version_info

  \"$(1)\" = {\
$(foreach host,$(hosts),$(call gen_host_version_info,$(1),$(host)))
  };
endef

define gen_info
{\
$(foreach version,$(versions),$(call gen_version_info,$(version)))
}
endef

empty :=
space := $(empty) $(empty)

define newline


endef

trim_trailing_spaces_helper = $(subst $(1)$(newline),$(newline),$(2))
trim_trailing_spaces = $(call trim_trailing_spaces_helper,$(space),$(call trim_trailing_spaces_helper,$(space)$(space),$(call trim_trailing_spaces_helper,$(space)$(space)$(space),$(1))))
post_process = $(subst $(newline),\n,$(call trim_trailing_spaces,$(1)))

.PHONY: zephyr-sdk-hash.nix
gen-hash-map: zephyr-sdk-hash.nix
zephyr-sdk-hash.nix: fetch-hash
	@printf "$(call post_process,$(call gen_info))" > $@
