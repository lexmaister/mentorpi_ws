#!/usr/bin/env bash
set -euo pipefail

mode="${1:-full}"

if [ -d /ws ] && [ -f /ws/scripts/dev_env.sh ]; then
  # Running inside the container.
  set +u
  source /ws/scripts/dev_env.sh
  set -u
  cd /ws
  if [ "$mode" = "light" ]; then
    colcon build --symlink-install --packages-ignore ascamera
  else
    if [ -f /ws/SOURCES/hp60c_depth_camera/linux_ros_SDK/ros2/composition.tar.xz ]; then
      /ws/scripts/provision_ascamera_libs.sh
    else
      echo "Archive not mounted in container; using currently provisioned libs from src/ascamera/libs/lib"
    fi
    colcon build --symlink-install
  fi
  set +u
  source /ws/install/setup.bash
  set -u
  echo "Build finished (container): mode=$mode"
  exit 0
fi

# Running on host: execute build inside container.
if ! docker compose ps --status running --services | grep -q '^mentorpi_dev$'; then
  echo "mentorpi_dev is not running."
  echo "Run: ./scripts/up.sh"
  exit 1
fi

case "$mode" in
  light)
    build_line='colcon build --symlink-install --packages-ignore ascamera'
    ;;
  full)
    ./scripts/provision_ascamera_libs.sh
    build_line='colcon build --symlink-install'
    ;;
  *)
    echo "Usage: $0 [full|light]"
    echo "  full  - build entire workspace"
    echo "  light - build while skipping ascamera"
    exit 2
    ;;
esac

docker compose exec mentorpi_dev bash -lc "source /ws/scripts/dev_env.sh && cd /ws && ${build_line} && source /ws/install/setup.bash"
echo "Build finished (host->container): mode=$mode"
