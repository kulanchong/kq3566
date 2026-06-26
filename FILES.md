# Adaptation File List

This repository is intentionally not a full ImmortalWrt source tree. It
contains KQ3566 adaptation patches and automation files only.

## Repository Files

- `.github/workflows/build-kq3566.yml`
- `configs/kq3566.config`
- `docs/github-actions.md`
- `docs/kq3566.md`
- `patches/master/0001-rockchip-add-KQ3566-board-support.patch`
- `patches/openwrt-25.12/0001-rockchip-add-KQ3566-board-support.patch`
- `patches/openwrt-24.10/0001-rockchip-add-KQ3566-board-support.patch`
- `scripts/collect-kq3566-artifacts.sh`
- `scripts/prepare-kq3566-build.sh`

## OpenWrt/ImmortalWrt Paths

The patches touch these OpenWrt/ImmortalWrt paths:

- `docs/kq3566.md`
- `package/boot/arm-trusted-firmware-rockchip/Makefile`
- `package/boot/arm-trusted-firmware-rockchip/atf-version.mk`
- `package/boot/uboot-envtools/files/fw_defaults` on `openwrt-24.10`
- `package/boot/uboot-tools/uboot-envtools/files/fw_defaults` on `openwrt-25.12` and `master`
- `package/boot/uboot-rockchip/Makefile`
- `package/boot/uboot-rockchip/src/arch/arm/dts/rk3566-kq3566-u-boot.dtsi`
- `package/boot/uboot-rockchip/src/arch/arm/dts/rk3566-kq3566.dts`
- `package/boot/uboot-rockchip/src/configs/kq3566-rk3566_defconfig`
- `target/linux/rockchip/armv8/base-files/etc/board.d/01_leds`
- `target/linux/rockchip/armv8/base-files/etc/board.d/02_network`
- `target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity`
- `target/linux/rockchip/armv8/base-files/lib/preinit/05_set_preinit_iface_kq3566`
- `target/linux/rockchip/image/armv8.mk`
- `target/linux/rockchip/modules.mk` on `openwrt-24.10`
- `target/linux/rockchip/patches-6.6/011-07-arm64-dts-rockchip-add-kq3566-board.patch`
- `target/linux/rockchip/patches-6.12/611-arm64-dts-rockchip-add-kq3566-board.patch`
- `target/linux/rockchip/patches-6.18/611-arm64-dts-rockchip-add-kq3566-board.patch`

Use `patches/openwrt-25.12/0001-rockchip-add-KQ3566-board-support.patch`
for current official ImmortalWrt `openwrt-25.12`.

Use `patches/master/0001-rockchip-add-KQ3566-board-support.patch`
for upstream ImmortalWrt `master`.

Use `patches/openwrt-24.10/0001-rockchip-add-KQ3566-board-support.patch`
for the older tested `openwrt-24.10` tree.
