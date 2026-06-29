# KQ3566 OpenWrt/ImmortalWrt Adaptation

This repository contains only the KQ3566 board adaptation files for
ImmortalWrt/OpenWrt. It is not a full OpenWrt source tree.

Base tree used for board bring-up and local hardware validation:

- ImmortalWrt `openwrt-24.10`
- Base commit: `07972a2388131947da9cbe334fb56ad52b8aab80`
- KQ3566 adaptation commit: `f8e16f52d40eacb3ad9f38e3fb49ee9995689062`

The repository also contains a GitHub Actions workflow that builds from
the official ImmortalWrt repository and publishes firmware to Releases.

Default automatic build source:

- Repository: `https://github.com/immortalwrt/immortalwrt`
- Ref: `openwrt-25.12`
- Patch: `patches/openwrt-25.12/0001-rockchip-add-KQ3566-board-support.patch`

The `openwrt-25.12` patch is the default CI path. It has been checked
against a clean official `openwrt-25.12` tree and through
`make target/linux/prepare` for the Rockchip 6.12 kernel patch stage.

## Apply

From a clean ImmortalWrt source tree:

```sh
git checkout openwrt-25.12
git apply /path/to/kq3566/patches/openwrt-25.12/0001-rockchip-add-KQ3566-board-support.patch
```

For the upstream `master` tree:

```sh
git checkout master
git apply /path/to/kq3566/patches/master/0001-rockchip-add-KQ3566-board-support.patch
```

For the older tested `openwrt-24.10` tree:

```sh
git checkout openwrt-24.10
git apply /path/to/kq3566/patches/openwrt-24.10/0001-rockchip-add-KQ3566-board-support.patch
```

Then build with:

```sh
make menuconfig
```

Select:

```text
Target System: Rockchip
Subtarget: ARMv8 boards
Target Profile: KQ KQ3566
```

Build:

```sh
make -j$(nproc) V=s
```

Expected output directory:

```text
bin/targets/rockchip/armv8/
```

Expected KQ3566 images:

```text
immortalwrt-rockchip-armv8-kq_kq3566-ext4-sysupgrade.img.gz
immortalwrt-rockchip-armv8-kq_kq3566-squashfs-sysupgrade.img.gz
immortalwrt-rockchip-armv8-kq_kq3566-ext4-emmc.img.gz
immortalwrt-rockchip-armv8-kq_kq3566-squashfs-emmc.img.gz
```

## Hardware Summary

- SoC: Rockchip RK3566
- RAM: DDR3, four NT5CC256M16ER-EK chips
- Internal Ethernet: RTL8211F-CG on GMAC/RGMII
- External Ethernet: RTL8111H-CG on PCIe
- PCIe PERSTB: GPIO0_B0
- SDMMC0 power enable: GPIO0_A5
- Recovery key: SARADC VIN0
- WORKING LED: GPIO0_C3
- RTL8211F WAN LEDs: green for link, amber for RX/TX activity,
  configured by `phy-leds` using the same RTL8211F hardware LED rules as R3S
- UART baud rate: 1500000

## DDR Loader

The tested loader for this board revision is
`rk3566_ddr_1056MHz_v1.25.bin` / `rk356x_spl_loader_kq_ddr_v1.25.bin`.
It is the KQ3566 RK3566 DDR3 loader for the current four-chip
NT5CC256M16ER-EK DDR3 layout. Treat it as the standard loader for this
KQ3566 hardware revision, not as a universal RK356x loader.

Use this loader for MaskROM/RKDevTool flashing, especially on blank or
replaced eMMC. Normal OpenWrt sysupgrade or LuCI firmware upgrade does
not need to rewrite the loader. Re-test or rebuild the loader if the DDR
part, topology, voltage, or routing changes.

More board notes are in `docs/kq3566.md`.

## Automatic Build

The workflow `.github/workflows/build-kq3566.yml` supports manual,
scheduled, and push-triggered builds. It can customize:

- official ImmortalWrt source ref, default `openwrt-25.12`
- default LAN and preinit IP
- extra feeds
- packages and package options
- release timezone

Finished firmware is uploaded as a workflow artifact and pushed to GitHub
Releases. Release titles include date and model, for example:

```text
2026-06-26 KQ3566 ImmortalWrt
```

See `docs/github-actions.md` for variable names and examples.
