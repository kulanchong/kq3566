# KQ3566 OpenWrt/ImmortalWrt Adaptation

This repository contains only the KQ3566 board adaptation files for
ImmortalWrt/OpenWrt. It is not a full OpenWrt source tree.

Base tree used for testing:

- ImmortalWrt `openwrt-24.10`
- Base commit: `07972a2388131947da9cbe334fb56ad52b8aab80`
- KQ3566 adaptation commit: `f8e16f52d40eacb3ad9f38e3fb49ee9995689062`

## Apply

From a clean ImmortalWrt source tree:

```sh
git checkout openwrt-24.10
git am /path/to/kq3566/patches/openwrt-24.10/0001-rockchip-add-KQ3566-board-support.patch
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
- UART baud rate: 1500000

More board notes are in `docs/kq3566.md`.
