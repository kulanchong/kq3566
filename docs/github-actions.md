# GitHub Actions Firmware Build

The workflow in `.github/workflows/build-kq3566.yml` builds KQ3566 firmware
from the official ImmortalWrt repository:

```text
https://github.com/immortalwrt/immortalwrt
```

By default it follows the official `openwrt-25.12` branch, applies the
KQ3566 25.12 adaptation patch, builds the firmware, uploads the workflow
artifact, and publishes a GitHub Release. The release title includes the
build date and model name.

The default build also enables TurboACC with Shortcut-FE/SFE instead of
Linux nftables flow offload. The workflow adds the TurboACC LuCI feed
automatically, and `scripts/prepare-kq3566-build.sh` copies the matching
`shortcut-fe`/`fast-classifier` package sources and kernel patches for the
current Rockchip kernel patch version.

## Automatic Triggers

- Manual run: Actions -> Build KQ3566 ImmortalWrt -> Run workflow
- Push run: when this repository changes workflow, config, script, docs, or
  patch files
- Scheduled run: every Friday at 18:00 UTC

## Repository Variables

Set these under:

```text
Settings -> Secrets and variables -> Actions -> Variables
```

Supported variables:

- `IMMORTALWRT_REF`: official ImmortalWrt ref to build. Default: `openwrt-25.12`
- `DEFAULT_IP`: LAN and preinit/failsafe IP. Default: `192.168.1.1`
- `CUSTOM_FEEDS`: extra `feeds.conf` lines, one per line
- `CUSTOM_PACKAGES`: packages or full `CONFIG_PACKAGE_*` symbols to enable
- `DISABLE_PACKAGES`: packages to force-disable
- `RELEASE_TZ`: release date timezone. Default: `Asia/Shanghai`
- `ENABLE_TURBOACC_SFE`: set to `0` to skip the default Shortcut-FE/SFE
  source and patch installation. Default: `1`
- `TURBOACC_PACKAGE_REPO`: source repository for Shortcut-FE/SFE package
  files. Default: `https://github.com/chenmozhijin/turboacc.git`
- `TURBOACC_PACKAGE_REF`: ref for the package source. Default: `package`

Manual workflow inputs override repository variables for that run.

## Examples

Default IP:

```text
DEFAULT_IP=192.168.66.1
```

Enable packages:

```text
CUSTOM_PACKAGES=luci-app-upnp luci-i18n-upnp-zh-cn htop nano
```

Enable package options:

```text
CUSTOM_PACKAGES=CONFIG_PACKAGE_luci-app-passwall=y CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Xray=y
```

Add a custom feed:

```text
CUSTOM_FEEDS=src-git custom https://github.com/example/openwrt-packages.git
```

Build the default 25.12 branch manually:

```text
source_ref=openwrt-25.12
```

Build the older tested 24.10 branch manually:

```text
source_ref=openwrt-24.10
```

When `source_ref` is `openwrt-25.12`, the workflow uses the
`patches/openwrt-25.12` adaptation patch. When `source_ref` is
`openwrt-24.10`, it uses the `patches/openwrt-24.10` patch. Other refs
use the `patches/master` patch.
