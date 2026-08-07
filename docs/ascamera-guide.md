# Ascamera Package Guide

This guide explains how to use the `ascamera` package in this workspace, what is required in Docker, and when to use USB-camera fallback.

## 1. What `ascamera` is

`ascamera` (under `src/ascamera`) is a vendor depth-camera ROS 2 package.

- Node executable: `ascamera_node`
- Default launch: `ros2 launch ascamera ascamera.launch.py`
- Namespace used by launch: `/ascamera`

The launch sets:

- parameter `confiPath` to `./ascamera/configurationfiles`

## 2. Build considerations

`ascamera` is C++ and links vendor-provided native libraries from `src/ascamera/libs/lib/<gcc-target>`.

Practical implications:

- Build can fail if dependencies/libraries are unavailable for your architecture.
- Runtime can fail if USB permissions/device access are missing.

Before building, provision vendor libs once:

```bash
./scripts/provision_ascamera_libs.sh
```

Then build normally:

```bash
cd /ws
colcon build --symlink-install
```

Fallback when vendor libs are intentionally unavailable:

```bash
./scripts/rebuild.sh light
```

## 3. Docker requirements for `ascamera`

### 3.1 Device access

At minimum, camera device nodes must be visible in container.

Current `compose.yml` maps:

- `/dev/video0`
- `/dev/video1`

And adds:

- `group_add: [video]`

If your device path differs, update `compose.yml` accordingly and recreate container.

### 3.2 Optional fallback for hard device-permission setups

If targeted mapping fails (common in some VM passthrough setups), temporary fallback:

```yaml
privileged: true
devices:
  - /dev:/dev
```

Use only for diagnostics, then tighten back to explicit device mappings.

### 3.3 Recommended runtime env

Inside container before launch (if you entered via `./scripts/up.sh` or `docker compose exec mentorpi_dev bash`, this is already set):

```bash
export need_compile=True
```

## 4. Running `ascamera`

### 4.1 Launch form

```bash
ros2 launch ascamera ascamera.launch.py
```

### 4.2 Direct node form

If you need direct execution:

```bash
ros2 run ascamera ascamera_node
```

### 4.3 Script helper

`./scripts/run_ascamera_node.sh` exists but expects environment details and may escalate privileges if udev rule is missing. Prefer explicit commands in this guide while debugging.

## 5. Verifying output

Use ROS tools:

```bash
ros2 topic list | grep ascamera
ros2 node list | grep ascamera
```

Check expected image-like topics if launch is successful.

## 6. Using USB webcam instead of `ascamera`

Many MentorPi examples only need RGB image topics and can run with USB camera remapped to expected `ascamera` topic names.

Use:

```bash
export DEPTH_CAMERA_TYPE=usb_cam
ros2 launch peripherals usb_cam.launch.py
```

This publishes to topics like:

- `/ascamera/camera_publisher/rgb0/image`
- `/ascamera/camera_publisher/rgb0/camera_info`

## 7. Pixel format caveat

`src/MentorPi/peripherals/config/usb_cam_param.yaml` defaults to `pixel_format: yuyv`.

If your webcam supports MJPEG only, set:

- `pixel_format: mjpeg2rgb`

Otherwise `usb_cam` may fail to start.

## 8. Choosing between depth modes

`src/MentorPi/peripherals/launch/depth_camera.launch.py` switches by env var:

- `DEPTH_CAMERA_TYPE=ascamera` -> vendor depth launch
- other value (for example `usb_cam`) -> USB camera launch + static TF

Use this to keep the same high-level launch flow across hardware and non-hardware setups.