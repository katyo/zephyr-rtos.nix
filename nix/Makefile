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
put_hash_helper = $(if $(3),printf '$(1)$(2) = {\n$(1)  file = "$(4)";\n$(1)  hash = "$(3)";\n$(1)};\n' >> $@;)

# args: ident, pfx, version, file pfx
put_hash = $(call put_hash_helper,$(1),$(2),$(call hash_get,$(3),sha256,$(4)),$(call file_get,$(3),sha256,$(4)))

.PHONY: zephyr-sdk-hash.nix
gen-hash-map: zephyr-sdk-hash.nix
zephyr-sdk-hash.nix: fetch-hash
	@echo '{' > $@;
	@$(foreach version,$(versions), \
		echo '  "$(version)" = {' >> $@; \
		$(foreach host,$(hosts), \
			echo '    "$(host)" = {' >> $@; \
			$(call put_hash,      ,hosttools,$(version),$(call hosttools_file,$(host))) \
			$(call put_hash,      ,full,$(version),$(call sdk_full_file,$(version),$(host))) \
			$(call put_hash,      ,minimal,$(version),$(call sdk_min_file,$(version),$(host))) \
			echo '      toolchains = {' >> $@; \
			$(foreach toolchain,$(toolchains), \
				$(call put_hash,        ,"$(toolchain)",$(version),$(call toolchain_file,$(host),$(toolchain))) \
			) \
			echo '      };' >> $@; \
			echo '    };' >> $@; \
		) \
		echo '  };' >> $@; \
	)
	@echo '}' >> $@
