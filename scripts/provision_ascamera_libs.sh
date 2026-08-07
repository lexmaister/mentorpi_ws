#!/usr/bin/env bash
set -euo pipefail

if [ -d /ws ] && [ -f /ws/src/ascamera/CMakeLists.txt ]; then
  ws_root="/ws"
  host_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
else
  ws_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  host_root="$ws_root"
fi

archive="$ws_root/SOURCES/hp60c_depth_camera/linux_ros_SDK/ros2/composition.tar.xz"
if [ ! -f "$archive" ] && [ -f "$host_root/SOURCES/hp60c_depth_camera/linux_ros_SDK/ros2/composition.tar.xz" ]; then
  archive="$host_root/SOURCES/hp60c_depth_camera/linux_ros_SDK/ros2/composition.tar.xz"
fi

libs_dst="$ws_root/src/ascamera/libs/lib"

if [ ! -f "$archive" ]; then
  if find "$libs_dst" -maxdepth 2 -type f -name 'libAngstrongCameraSdk.so' | grep -q .; then
    echo "Archive not found, but ascamera libs already present in: $libs_dst"
    exit 0
  fi
  echo "Missing archive: $archive"
  echo "Run this script from host workspace root where SOURCES/ exists."
  exit 1
fi

mkdir -p "$libs_dst"

tmp_dir="$(mktemp -d)"
cleanup() { rm -rf "$tmp_dir"; }
trap cleanup EXIT

echo "Extracting vendor libs from composition archive..."
tar -xJf "$archive" -C "$tmp_dir" composition/libs/lib

cp -a "$tmp_dir/composition/libs/lib/." "$libs_dst/"

echo "Installed ascamera vendor libs into: $libs_dst"
find "$libs_dst" -maxdepth 2 -type f -name 'libAngstrongCameraSdk.so' -o -name 'libFilt.so' -o -name 'libasuvc.so' -o -name 'libasusb.so' -o -name 'libturbojpeg.so' -o -name 'libalg_kunlun.so' -o -name 'libAngKondyorArith.so' | sed -n '1,50p'
