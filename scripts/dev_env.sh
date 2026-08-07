#!/usr/bin/env bash
# Shared MentorPi workspace environment for interactive container sessions.

# Always source ROS first.
if [ -f /opt/ros/humble/setup.bash ]; then
  source /opt/ros/humble/setup.bash
fi

# Source local workspace if it has been built.
if [ -f /ws/install/setup.bash ]; then
  source /ws/install/setup.bash
fi

# Keep launch behavior workspace-friendly and avoid upstream hard-coded paths.
export need_compile=True

# Preserve existing user choice if already set; otherwise apply defaults.
export DEPTH_CAMERA_TYPE="${DEPTH_CAMERA_TYPE:-usb_cam}"
export HOST="${HOST:-/}"
export MASTER="${MASTER:-/}"
export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-0}"
export ROS_LOCALHOST_ONLY="${ROS_LOCALHOST_ONLY:-0}"

# Optional .typerc values for compatibility (mounted from scripts/.typerc).
# Keep current shell values if present.
if [ -f /ws/.typerc ]; then
  # shellcheck source=/dev/null
  source /ws/.typerc >/dev/null 2>&1 || true
  export need_compile=True
  export DEPTH_CAMERA_TYPE="${DEPTH_CAMERA_TYPE:-usb_cam}"
  export HOST="${HOST:-/}"
  export MASTER="${MASTER:-/}"
  export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-0}"
  export ROS_LOCALHOST_ONLY="${ROS_LOCALHOST_ONLY:-0}"
fi

echo "MentorPi dev environment ready"
echo "need_compile=${need_compile} DEPTH_CAMERA_TYPE=${DEPTH_CAMERA_TYPE} ROS_DOMAIN_ID=${ROS_DOMAIN_ID}"
