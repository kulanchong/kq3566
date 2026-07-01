#!/usr/bin/env bash
set -euo pipefail

build_dir="${1:-immortalwrt}"
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config_fragment="${CONFIG_FRAGMENT:-$repo_dir/configs/kq3566.config}"
default_ip="${DEFAULT_IP:-192.168.1.1}"
custom_packages="${CUSTOM_PACKAGES:-}"
disable_packages="${DISABLE_PACKAGES:-}"
enable_turboacc_sfe="${ENABLE_TURBOACC_SFE:-1}"
turboacc_package_repo="${TURBOACC_PACKAGE_REPO:-https://github.com/chenmozhijin/turboacc.git}"
turboacc_package_ref="${TURBOACC_PACKAGE_REF:-package}"

if [ ! -d "$build_dir" ]; then
	echo "Build directory does not exist: $build_dir" >&2
	exit 1
fi

if [ ! -f "$config_fragment" ]; then
	echo "Config fragment does not exist: $config_fragment" >&2
	exit 1
fi

if ! printf '%s\n' "$default_ip" | grep -Eq '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
	echo "DEFAULT_IP must be an IPv4 address, got: $default_ip" >&2
	exit 1
fi

append_package_list() {
	local list="$1"
	local mode="$2"
	local item symbol

	printf '%s\n' "$list" | tr ',;\r\t ' '\n' | while IFS= read -r item; do
		[ -n "$item" ] || continue
		case "$item" in
			\#*) continue ;;
		esac

		if [ "$mode" = "enable" ]; then
			case "$item" in
				CONFIG_*=*) printf '%s\n' "$item" ;;
				CONFIG_PACKAGE_*) printf '%s=y\n' "$item" ;;
				*) printf 'CONFIG_PACKAGE_%s=y\n' "$item" ;;
			esac
		else
			symbol="${item#CONFIG_PACKAGE_}"
			symbol="${symbol%%=*}"
			printf '# CONFIG_PACKAGE_%s is not set\n' "$symbol"
		fi
	done
}

install_turboacc_sfe() {
	local kernel_patchver tmpdir patch_kind patch_src patch_dst turboacc_config

	[ "$enable_turboacc_sfe" = "1" ] || return 0

	kernel_patchver="$(
		sed -n 's/^KERNEL_PATCHVER:=//p' "$build_dir/target/linux/rockchip/Makefile" |
			tr -d '[:space:]' |
			head -n 1
	)"

	if [ -z "$kernel_patchver" ]; then
		echo "Unable to detect rockchip KERNEL_PATCHVER" >&2
		exit 1
	fi

	tmpdir="$(mktemp -d)"

	git clone --depth 1 "$turboacc_package_repo" "$tmpdir/turboacc-package"
	git -C "$tmpdir/turboacc-package" fetch --depth 1 origin "$turboacc_package_ref"
	git -C "$tmpdir/turboacc-package" checkout --detach FETCH_HEAD

	if [ ! -d "$tmpdir/turboacc-package/shortcut-fe" ]; then
		echo "TurboACC package source is missing shortcut-fe" >&2
		exit 1
	fi

	rm -rf "$build_dir/package/kernel/shortcut-fe"
	mkdir -p "$build_dir/package/kernel"
	cp -a "$tmpdir/turboacc-package/shortcut-fe" "$build_dir/package/kernel/shortcut-fe"

	for patch_kind in hack pending; do
		patch_src="$tmpdir/turboacc-package/${patch_kind}-${kernel_patchver}"
		patch_dst="$build_dir/target/linux/generic/${patch_kind}-${kernel_patchver}"

		if [ ! -d "$patch_src" ]; then
			echo "TurboACC package source has no ${patch_kind}-${kernel_patchver} patches" >&2
			exit 1
		fi

		mkdir -p "$patch_dst"
		cp -a "$patch_src"/*.patch "$patch_dst"/
	done

	turboacc_config="$build_dir/package/feeds/turboacc/luci-app-turboacc/root/etc/config/turboacc"
	if [ ! -f "$turboacc_config" ]; then
		echo "luci-app-turboacc feed is missing. Check feeds.conf.default or CUSTOM_FEEDS." >&2
		exit 1
	fi

	sed -i \
		-e "s/option sw_flow .*/option sw_flow '0'/" \
		-e "s/option hw_flow .*/option hw_flow '0'/" \
		-e "s/option sfe_flow .*/option sfe_flow '1'/" \
		"$turboacc_config"

	rm -rf "$tmpdir"

	echo "Installed TurboACC Shortcut-FE support for Linux ${kernel_patchver}"
}

third_octets="${default_ip%.*}"
preinit_broadcast="${third_octets}.255"

cp "$config_fragment" "$build_dir/.config"
{
	printf '\n# KQ3566 CI default network\n'
	printf 'CONFIG_TARGET_PREINIT_IP="%s"\n' "$default_ip"
	printf 'CONFIG_TARGET_PREINIT_NETMASK="255.255.255.0"\n'
	printf 'CONFIG_TARGET_PREINIT_BROADCAST="%s"\n' "$preinit_broadcast"
	append_package_list "$custom_packages" enable
	append_package_list "$disable_packages" disable
} >> "$build_dir/.config"

if [ "$enable_turboacc_sfe" != "1" ]; then
	cat >> "$build_dir/.config" <<'EOF'
# CONFIG_PACKAGE_luci-app-turboacc is not set
# CONFIG_PACKAGE_luci-i18n-turboacc-zh-cn is not set
# CONFIG_PACKAGE_kmod-fast-classifier is not set
# CONFIG_PACKAGE_kmod-shortcut-fe is not set
EOF
fi

mkdir -p "$build_dir/files/etc/uci-defaults"
cat > "$build_dir/files/etc/uci-defaults/99-kq3566-default-ip" <<EOF
#!/bin/sh
uci -q set network.lan.proto='static'
uci -q set network.lan.ipaddr='$default_ip'
uci -q set network.lan.netmask='255.255.255.0'
uci -q commit network
exit 0
EOF
chmod 0755 "$build_dir/files/etc/uci-defaults/99-kq3566-default-ip"

install_turboacc_sfe

make -C "$build_dir" defconfig

required_symbols="
CONFIG_PACKAGE_luci
CONFIG_PACKAGE_luci-base
CONFIG_PACKAGE_luci-mod-admin-full
CONFIG_PACKAGE_luci-theme-bootstrap
CONFIG_PACKAGE_uhttpd
CONFIG_PACKAGE_uhttpd-mod-ubus
CONFIG_PACKAGE_rpcd
CONFIG_PACKAGE_rpcd-mod-luci
"

if [ "$enable_turboacc_sfe" = "1" ]; then
	required_symbols="$required_symbols
CONFIG_PACKAGE_luci-app-turboacc
CONFIG_PACKAGE_kmod-fast-classifier
CONFIG_PACKAGE_kmod-shortcut-fe
"
fi

for symbol in $required_symbols; do
	if ! grep -qx "${symbol}=y" "$build_dir/.config"; then
		echo "Required web UI symbol is missing after defconfig: $symbol" >&2
		exit 1
	fi
done

echo "KQ3566 build config prepared"
echo "DEFAULT_IP=$default_ip"
echo "CUSTOM_PACKAGES=${custom_packages:-<none>}"
echo "DISABLE_PACKAGES=${disable_packages:-<none>}"
echo "ENABLE_TURBOACC_SFE=$enable_turboacc_sfe"
