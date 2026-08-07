# Docker Setup and Daily Workflow

This guide explains how to set up and use this workspace on any Linux PC path, without relying on the original upstream directory layout.

## 1. Prerequisites

Install on host:

- Docker Engine
- Docker Compose plugin
- Git

Optional but useful:

- `v4l-utils` for webcam diagnostics (`v4l2-ctl`)

Verify:

```bash
docker --version
docker compose version
git --version
```

## 2. Workspace location

Clone this repository to any Linux path, for example:

```bash
mkdir -p ~/projects
cd ~/projects
git clone https://github.com/lexmaister/mentorpi_ws.git mentorpi_ws
cd mentorpi_ws
```

No hard dependency exists on a specific host path. Container workspace root is always `/ws`.

## 2.1 Populate external MentorPi source

This workspace can be used with an external MentorPi source tree. If `src/MentorPi` is empty after cloning this repo, populate it now:

```bash
git clone --branch MentorPi-M1 https://github.com/Hiwonder/MentorPi.git src/MentorPi
```

Verify:

```bash
ls src/MentorPi
```

Expected content includes folders such as `app`, `bringup`, `driver`, `peripherals`, and `slam`.

## 3. Compose and Docker design

Current setup in `compose.yml`:

- bind mount: `./src:/ws/src`
- bind mount: `./scripts:/ws/scripts:ro`
- bind mount: `./scripts/.typerc:/ws/.typerc:ro`
- persistent named volumes:
  - `mentorpi_build:/ws/build`
  - `mentorpi_install:/ws/install`
  - `mentorpi_log:/ws/log`
- networking: `network_mode: host`
- GUI support:
  - `DISPLAY` environment
  - `/tmp/.X11-unix` mounted
- camera devices:
  - `/dev/video0` and `/dev/video1` mapped
  - container added to `video` group

Why this matters:

- source code is editable from host IDE
- ROS build artifacts persist across container restarts
- avoids polluting host repo with `build/ install/ log/`
- DDS discovery is easier with host networking on Linux

## 4. Build and enter container

From repository root:

```bash
xhost +local:docker
docker compose build
./scripts/provision_ascamera_libs.sh
./scripts/up.sh
```

Direct alternative:

```bash
./scripts/provision_ascamera_libs.sh
docker compose up -d
docker compose exec mentorpi_dev bash
```

Additional host/container helpers:

- `./scripts/rebuild.sh full` (auto-provisions `ascamera` libs)
- `./scripts/rebuild.sh light`
- `./scripts/camera_doctor.sh`
- `./scripts/provision_ascamera_libs.sh`

Container shells source `/ws/scripts/dev_env.sh` from `/root/.bashrc`.

`scripts/dev_env.sh` sets a ready-to-use environment for this workspace:

- ROS and workspace setup files
- `need_compile=True` to avoid upstream fallback paths
- defaults for `DEPTH_CAMERA_TYPE`, `HOST`, `MASTER`, and ROS networking vars

## 5. Build workspace

Inside container:

```bash
cd /ws
colcon build --symlink-install
```

The provisioning step extracts required `ascamera` vendor libraries from
`SOURCES/hp60c_depth_camera/linux_ros_SDK/ros2/composition.tar.xz`
into `src/ascamera/libs/lib`.

Fallback mode when those vendor binaries are intentionally unavailable:

```bash
./scripts/rebuild.sh light
```

## 6. Recommended daily loop

1. Start container:

```bash
docker compose up -d
```

2. Enter container:

```bash
docker compose exec mentorpi_dev bash
```

If needed, manually reload environment inside container:

```bash
source /ws/scripts/dev_env.sh
```

3. Build only what changed:

```bash
cd /ws
colcon build --symlink-install
```

4. Run launch/nodes.

## 7. GUI notes (RViz/OpenCV)

If GUI tools fail to open:

```bash
xhost +local:docker
echo $DISPLAY
```

Inside container, verify:

```bash
echo $DISPLAY
```

## 8. Required apt packages for common workflows

Base image already installs many essentials in `Dockerfile`. For camera/perception workflows, you may also need inside container:

```bash
apt update
apt install -y ros-humble-usb-cam ros-humble-vision-msgs
```

For YOLO examples (Python side):

```bash
pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple yolov5
```

## 9. Rebuild behavior

Container restart does not force clean ROS rebuild because `build/install/log` are Docker volumes.

You need `colcon build` when:

- package sources changed
- `package.xml` or `CMakeLists.txt` changed
- new packages were added

## 10. Shutdown and cleanup

Stop container:

```bash
docker compose down
```

Stop and remove build/install/log volumes too:

```bash
docker compose down -v
```

Use `-v` only when you intentionally want a clean rebuild next time.