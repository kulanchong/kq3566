#!/usr/bin/env bash
set -euo pipefail

build_dir="${1:-immortalwrt}"
out_dir="${2:-artifacts}"
target_dir="$build_dir/bin/targets/rockchip/armv8"

if [ ! -d "$target_dir" ]; then
	echo "Target output directory does not exist: $target_dir" >&2
	exit 1
fi

rm -rf "$out_dir"
mkdir -p "$out_dir"

shopt -s nullglob
kq_files=("$target_dir"/*kq_kq3566*)
manifest_file="$target_dir/immortalwrt-rockchip-armv8-kq_kq3566.manifest"

if [ "${#kq_files[@]}" -eq 0 ]; then
	echo "No KQ3566 firmware files found in $target_dir" >&2
	exit 1
fi

if [ ! -f "$manifest_file" ]; then
	echo "KQ3566 manifest not found: $manifest_file" >&2
	exit 1
fi

required_packages="
luci
luci-base
luci-mod-admin-full
luci-theme-bootstrap
uhttpd
uhttpd-mod-ubus
rpcd
rpcd-mod-luci
"

for package in $required_packages; do
	if ! grep -Eq "^${package}[[:space:]]+-" "$manifest_file"; then
		echo "Required web UI package is missing from firmware manifest: $package" >&2
		exit 1
	fi
done

cp "${kq_files[@]}" "$out_dir/"

for extra in sha256sums profiles.json config.buildinfo feeds.buildinfo version.buildinfo; do
	if [ -f "$target_dir/$extra" ]; then
		cp "$target_dir/$extra" "$out_dir/openwrt-$extra"
	fi
done

(
	cd "$out_dir"
	rm -f SHA256SUMS
	sha256sum * > SHA256SUMS
)

echo "Collected KQ3566 artifacts:"
find "$out_dir" -maxdepth 1 -type f -printf '  %f\n' | sort
