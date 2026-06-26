#!/usr/bin/env bash
set -euo pipefail

build_dir="${1:-immortalwrt}"
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config_fragment="${CONFIG_FRAGMENT:-$repo_dir/configs/kq3566.config}"
default_ip="${DEFAULT_IP:-192.168.1.1}"
custom_packages="${CUSTOM_PACKAGES:-}"
disable_packages="${DISABLE_PACKAGES:-}"

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

mkdir -p "$build_dir/files/etc/uci-defaults"
cat > "$build_dir/files/etc/uci-defaults/99-kq3566-default-ip" <<EOF
#!/bin/sh
uci -q set network.lan.ipaddr='$default_ip'
uci -q commit network
exit 0
EOF
chmod 0755 "$build_dir/files/etc/uci-defaults/99-kq3566-default-ip"

make -C "$build_dir" defconfig

echo "KQ3566 build config prepared"
echo "DEFAULT_IP=$default_ip"
echo "CUSTOM_PACKAGES=${custom_packages:-<none>}"
echo "DISABLE_PACKAGES=${disable_packages:-<none>}"
