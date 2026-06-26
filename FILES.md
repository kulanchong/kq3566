# Adaptation File List

The patch touches these OpenWrt/ImmortalWrt paths:

- `docs/kq3566.md`
- `package/boot/arm-trusted-firmware-rockchip/Makefile`
- `package/boot/arm-trusted-firmware-rockchip/atf-version.mk`
- `package/boot/uboot-envtools/files/fw_defaults`
- `package/boot/uboot-rockchip/Makefile`
- `package/boot/uboot-rockchip/src/arch/arm/dts/rk3566-kq3566-u-boot.dtsi`
- `package/boot/uboot-rockchip/src/arch/arm/dts/rk3566-kq3566.dts`
- `package/boot/uboot-rockchip/src/configs/kq3566-rk3566_defconfig`
- `target/linux/rockchip/armv8/base-files/etc/board.d/01_leds`
- `target/linux/rockchip/armv8/base-files/etc/board.d/02_network`
- `target/linux/rockchip/armv8/base-files/etc/hotplug.d/net/40-net-smp-affinity`
- `target/linux/rockchip/armv8/base-files/lib/preinit/05_set_preinit_iface_kq3566`
- `target/linux/rockchip/image/armv8.mk`
- `target/linux/rockchip/modules.mk`
- `target/linux/rockchip/patches-6.6/011-07-arm64-dts-rockchip-add-kq3566-board.patch`

Use `patches/openwrt-24.10/0001-rockchip-add-KQ3566-board-support.patch`
to apply all changes at once with `git am`.
