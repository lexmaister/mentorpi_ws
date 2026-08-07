# Working Without Full Robot Hardware

This guide describes what you can run on a Linux PC in Docker without the full MentorPi robot.

## 1. Supported modes

You can work in three practical modes:

1. Docker only (no camera): architecture study, package builds, RViz robot model
2. Docker + USB webcam: image-based demos and YOLO
3. Docker + robot depth/stereo camera: camera pipeline work without full chassis

## 2. Bring up container environment

Host:

```bash
./scripts/provision_ascamera_libs.sh
./scripts/up.sh
```

Container:

```bash
cd /ws
colcon build --symlink-install
```

Fallback if you intentionally skip vendor camera binaries:

```bash
./scripts/rebuild.sh light
```

Set common launch environment:

```bash
export HOST=/
export MASTER=/
```

## 3. Docker-only examples

### 3.1 Robot model visualization

```bash
ros2 launch mentorpi_description display.launch.py
```

Use this to inspect URDF/TF and RViz setup.

### 3.2 ROS graph checks

```bash
ros2 pkg list
ros2 topic list
ros2 node list
```

## 4. USB webcam examples

### 4.1 Ensure webcam is visible

Host:

```bash
ls -l /dev/video*
```

Container:

```bash
ls -l /dev/video*
```

### 4.2 Start webcam wrapper on MentorPi-compatible topics

```bash
export DEPTH_CAMERA_TYPE=usb_cam
ros2 launch peripherals usb_cam.launch.py
```

If launch crashes with `Specified format 'yuyv' is unsupported`, or if `usb_cam` starts but logs repeated `Failed to send AVPacket to decode` messages, avoid editing the vendored MentorPi config under `src/MentorPi/...`.

Use a direct `usb_cam` command line with explicit parameters and MentorPi-compatible remaps instead:

```bash
source /opt/ros/humble/setup.bash
source /ws/install/setup.bash

ros2 run usb_cam usb_cam_node_exe --ros-args \
	-p video_device:=/dev/video0 \
	-p image_width:=640 \
	-p image_height:=480 \
	-p framerate:=5.0 \
	-p pixel_format:=mjpeg2rgb \
	-p io_method:=mmap \
	-p brightness:=-1 \
	-p contrast:=-1 \
	-p saturation:=-1 \
	-p sharpness:=-1 \
	-p gain:=-1 \
	-p auto_white_balance:=true \
	-p white_balance:=-1 \
	-p autoexposure:=true \
	-p exposure:=-1 \
	-p autofocus:=false \
	-p focus:=-1 \
	-p camera_name:=usb_cam \
	-p camera_info_url:=package://peripherals/config/camera_info.yaml \
	-r image_raw:=/ascamera/camera_publisher/rgb0/image \
	-r image_raw/compressed:=/ascamera/camera_publisher/rgb0/image_compressed \
	-r image_raw/compressedDepth:=/ascamera/camera_publisher/rgb0/compressedDepth \
	-r image_raw/theora:=/ascamera/camera_publisher/rgb0/image_raw/theora \
	-r camera_info:=/ascamera/camera_publisher/rgb0/camera_info
```

This keeps the external MentorPi repository untouched while giving you a webcam profile that is often more stable for MJPEG-only devices and VirtualBox passthrough cameras.

Optional format probe:

```bash
apt update && apt install -y v4l-utils
v4l2-ctl --device=/dev/video0 --list-formats-ext
```

If the webcam still decodes badly at `640x480`, try `image_width:=320 image_height:=240` first, then increase resolution after the viewer is stable.

### 4.3 Verify stream

Keep `usb_cam` node running, then inspect the image stream in a second shell:

```bash
ros2 topic list | grep ascamera
ros2 topic hz /ascamera/camera_publisher/rgb0/image
```

and watch cam video:

```bash
ros2 run image_view image_view --ros-args -r image:=/ascamera/camera_publisher/rgb0/image
```

### 4.4 Run image-only examples

Example node that can run with webcam input:

```bash
ros2 run example hand_detect
```

Some launch files in `example` include controller/motion dependencies. Prefer direct nodes for hardware-light testing.

## 5. YOLO workflow without robot chassis

Install runtime deps (container):

```bash
apt update
apt install -y ros-humble-vision-msgs ros-humble-usb-cam
pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple yolov5
```

Run detector:

```bash
ros2 run yolov5_ros2 yolo_detect --ros-args -p device:=cpu -p image_topic:=/ascamera/camera_publisher/rgb0/image
```

Inspect output:

```bash
ros2 topic echo /yolo_result
```

## 6. Using only depth/stereo camera hardware

If you have the robot camera but not full robot chassis, use either:

- `ascamera` directly, or
- `peripherals/launch/depth_camera.launch.py` with `DEPTH_CAMERA_TYPE=ascamera`

This lets you validate camera topics and perception consumers independently from motor/controller layers.

## 7. Features that are usually robot-only

These typically depend on controller/lidar/IMU/chassis:

- `bringup/launch/bringup.launch.py`
- `driver/controller/launch/controller.launch.py`
- `peripherals/launch/lidar.launch.py`
- most SLAM/navigation full stacks
- many motion-centric `app` and `example` launches

You can still study them, but they are not turnkey without mocked inputs.

## 8. Known caveats

- Some launches fallback to `/home/ubuntu/ros2_ws/...` if `need_compile` is not `True`.
- Some demos expect external LAB config files not present in this repository.
- GUI windows require host X11 access (`xhost +local:docker`).

## 9. Practical learning path without robot

1. Start with robot model in RViz.
2. Add USB webcam pipeline.
3. Run image-based demos (`example` + `yolov5_ros2`).
4. Switch to real depth camera (`ascamera`) when available.
5. Move to hardware-dependent navigation/control only after perception stack is stable.