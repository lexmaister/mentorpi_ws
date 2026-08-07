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

### 4.3 Verify stream

```bash
ros2 topic list | grep ascamera
ros2 topic hz /ascamera/camera_publisher/rgb0/image
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