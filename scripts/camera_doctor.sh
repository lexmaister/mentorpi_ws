#!/usr/bin/env bash
set -euo pipefail

if [ ! -d /ws ]; then
  if ! docker compose ps --status running --services | grep -q '^mentorpi_dev$'; then
    echo "mentorpi_dev is not running."
    echo "Run: ./scripts/up.sh"
    exit 1
  fi
  docker compose exec mentorpi_dev bash -lc 'bash /ws/scripts/camera_doctor.sh'
  exit 0
fi

# ROS setup scripts reference variables that may be unset; temporarily relax nounset.
set +u
source /ws/scripts/dev_env.sh
set -u

echo "== Camera doctor =="
echo "need_compile=$need_compile DEPTH_CAMERA_TYPE=$DEPTH_CAMERA_TYPE"

echo
echo "[1/6] Device nodes"
if compgen -G "/dev/video*" >/dev/null; then
  ls -l /dev/video*
else
  echo "No /dev/video* devices visible inside container"
fi

echo
echo "[2/6] USB camera package"
if ros2 pkg prefix usb_cam >/dev/null 2>&1; then
  echo "usb_cam package: OK"
else
  echo "usb_cam package: MISSING"
fi

echo
echo "[3/6] MentorPi camera launch package"
if ros2 pkg prefix peripherals >/dev/null 2>&1; then
  echo "peripherals package: OK"
else
  echo "peripherals package: MISSING"
fi

echo
echo "[4/6] usb_cam config"
cfg="/ws/src/MentorPi/peripherals/config/usb_cam_param.yaml"
if [ -f "$cfg" ]; then
  grep -E "video_device|pixel_format|image_width|image_height|framerate" "$cfg" || true
else
  echo "Config not found: $cfg"
fi

echo
echo "[5/6] ROS topic snapshot (camera-related)"
ros2 topic list 2>/dev/null | grep -E "ascamera|camera|image" || echo "No camera topics yet"

echo
echo "[6/6] Suggested next commands"
echo "export DEPTH_CAMERA_TYPE=usb_cam"
echo "ros2 launch peripherals usb_cam.launch.py"
echo "ros2 topic hz /ascamera/camera_publisher/rgb0/image"
