# Command Cheat Sheet

This page is a copy-paste command index for daily MentorPi workspace usage.

## 1. Host-side container control

First-time source bootstrap (if `src/MentorPi` is empty):

```bash
git clone --branch MentorPi-M1 https://github.com/Hiwonder/MentorPi.git src/MentorPi
```

Start and enter:

```bash
./scripts/up.sh
```

Build image:

```bash
docker compose build
```

One-command up and enter:

```bash
./scripts/up.sh
```

Rebuild helpers (run from host):

```bash
./scripts/rebuild.sh full
./scripts/rebuild.sh light
```

Provision ascamera vendor libs (run once after clone/update):

```bash
./scripts/provision_ascamera_libs.sh
```

Camera diagnostics (run from host):

```bash
./scripts/camera_doctor.sh
```

Restart container:

```bash
docker compose down
docker compose up -d
```

Clean rebuild state (removes build/install/log volumes):

```bash
docker compose down -v
docker compose up -d
```

## 2. Inside-container environment and build

If you entered using `./scripts/up.sh` or `docker compose exec mentorpi_dev bash`, environment is already prepared.

Manual fallback:

```bash
source /ws/scripts/dev_env.sh
```

Build workspace quickly:

```bash
cd /ws
colcon build --symlink-install
```

Fallback build without ascamera:

```bash
./scripts/rebuild.sh light
```

Build selected packages only:

```bash
cd /ws
colcon build --symlink-install --packages-select peripherals example yolov5_ros2
```

## 3. Environment variables used in launches

Show current values:

```bash
env | grep -E 'need_compile|DEPTH_CAMERA_TYPE|ROS_DOMAIN_ID|HOST|MASTER'
```

Set webcam mode:

```bash
export DEPTH_CAMERA_TYPE=usb_cam
```

Set vendor depth camera mode:

```bash
export DEPTH_CAMERA_TYPE=ascamera
```

## 4. Robot-model and visualization

Run model display:

```bash
ros2 launch mentorpi_description display.launch.py
```

## 5. USB webcam workflows

Check camera devices (host and container):

```bash
ls -l /dev/video*
```

Start webcam with MentorPi-compatible topic names:

```bash
export DEPTH_CAMERA_TYPE=usb_cam
ros2 launch peripherals usb_cam.launch.py
```

Check stream:

```bash
ros2 topic list | grep ascamera
ros2 topic hz /ascamera/camera_publisher/rgb0/image
```

Run raw usb_cam node directly:

```bash
ros2 run usb_cam usb_cam_node_exe --ros-args -p video_device:=/dev/video0 -p image_width:=640 -p image_height:=480 -p framerate:=30.0
```

## 6. Ascamera workflows

Launch ascamera package:

```bash
export DEPTH_CAMERA_TYPE=ascamera
ros2 launch ascamera ascamera.launch.py
```

Check running node/topics:

```bash
ros2 node list | grep ascamera
ros2 topic list | grep ascamera
```

## 7. YOLO workflows

Install runtime deps (container):

```bash
apt update
apt install -y ros-humble-usb-cam ros-humble-vision-msgs
pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple yolov5
```

Run detector on webcam topic:

```bash
ros2 run yolov5_ros2 yolo_detect --ros-args -p device:=cpu -p image_topic:=/ascamera/camera_publisher/rgb0/image
```

Check outputs:

```bash
ros2 topic echo /yolo_result
```

## 8. External-PC debug quick checks

On both machines:

```bash
echo $ROS_DOMAIN_ID
echo $ROS_LOCALHOST_ONLY
```

On debug PC:

```bash
ros2 topic list
ros2 node list
```

## 9. Useful diagnostics

Package visibility:

```bash
ros2 pkg list | grep -E 'peripherals|ascamera|mentorpi_description|yolov5_ros2'
```

ROS graph:

```bash
ros2 topic list
ros2 node list
```

Container status:

```bash
docker compose ps
```

## 10. Most common fixes

If launch resolves wrong hard-coded paths:

```bash
export need_compile=True
```

If webcam format fails, adjust pixel format:

- `hx src/MentorPi/peripherals/config/usb_cam_param.yaml`
- try `pixel_format: mjpeg2rgb`

If you see this exact crash:

- `what(): Specified format 'yuyv' is unsupported by the selected device '/dev/video0'`

Use:

```bash
apt update && apt install -y v4l-utils
v4l2-ctl --device=/dev/video0 --list-formats-ext
# If only MJPEG modes appear, set pixel_format: mjpeg2rgb in usb_cam_param.yaml
ros2 launch peripherals usb_cam.launch.py
```
