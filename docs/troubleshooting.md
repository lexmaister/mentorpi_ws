# Troubleshooting

## 1. Container starts but ROS launch cannot find packages

Symptoms:

- `package not found`
- launch cannot resolve paths

Checks:

```bash
ros2 pkg list | grep -E 'peripherals|ascamera|mentorpi_description'
```

Fix:

- rebuild workspace:

```bash
cd /ws
colcon build --symlink-install
```

## 2. Launch fails with `/home/ubuntu/ros2_ws/...` paths

Cause:

- launch file fallback path used because `need_compile` not set

Fix:

```bash
export need_compile=True
```

## 3. Webcam not visible inside container

Checks:

Host:

```bash
ls -l /dev/video*
```

Container:

```bash
ls -l /dev/video*
```

Fixes:

- ensure `compose.yml` maps required `/dev/video*`
- recreate container after compose change:

```bash
docker compose down
docker compose up -d
```

## 4. `usb_cam` fails to start due to format

Cause:

- camera does not support default `yuyv`

Typical log:

- `what(): Specified format 'yuyv' is unsupported by the selected device '/dev/video0'`
- node prints only `Motion-JPEG ...` modes before terminating

Fix:

Open the config with Helix and set:

```bash
hx src/MentorPi/peripherals/config/usb_cam_param.yaml
```

- `pixel_format: mjpeg2rgb`

Then restart webcam launch:

```bash
export DEPTH_CAMERA_TYPE=usb_cam
ros2 launch peripherals usb_cam.launch.py
```

Optional pre-check to confirm supported formats:

```bash
apt update && apt install -y v4l-utils
v4l2-ctl --device=/dev/video0 --list-formats-ext
```

If your output lists only MJPEG modes, keep `pixel_format: mjpeg2rgb`.

## 5. GUI apps (RViz/OpenCV) do not open

Fixes:

```bash
xhost +local:docker
echo $DISPLAY
```

Make sure container has same `DISPLAY` env and `/tmp/.X11-unix` mount.

## 6. External PC cannot see robot topics

Checks:

```bash
echo $ROS_DOMAIN_ID
echo $ROS_LOCALHOST_ONLY
```

Fixes:

- set same `ROS_DOMAIN_ID` on both machines
- set `ROS_LOCALHOST_ONLY=0` on both
- verify network/firewall allows DDS discovery

## 7. `ascamera` build or runtime issues

Likely causes:

- missing/unsupported vendor native libs for architecture
- camera permissions or device mismatch

Fix order:

1. Provision vendor libs:

```bash
./scripts/provision_ascamera_libs.sh
```

2. Rebuild:

```bash
cd /ws
colcon build --symlink-install
```

Temporary workaround when vendor libs are unavailable:

- continue learning with USB camera fallback and build without `ascamera` first:

```bash
./scripts/rebuild.sh light
```

## 8. `No module named 'nav2_common'` during model visualization

Symptoms:

- `ros2 launch mentorpi_description display.launch.py` exits with:
	`Caught exception in launch ... No module named 'nav2_common'`

Cause:

- `mentorpi_description/launch/rviz.launch.py` imports `ReplaceString` from `nav2_common`.

Fix in an already running container:

```bash
apt update
apt install -y ros-humble-nav2-common
```

Then re-run:

```bash
ros2 launch mentorpi_description display.launch.py
```

Permanent fix:

- Rebuild the Docker image so new containers include this dependency:

```bash
docker compose build
docker compose up -d
```