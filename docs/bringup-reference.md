# MentorPi Bringup Reference

Detailed boot sequence and confirmed runtime graph produced by `bringup.launch.py`.

For the broader system architecture and package map see [mentorpi-ros-architecture.md](mentorpi-ros-architecture.md).

---

## Boot sequence

```
power on
  └─ Raspberry Pi OS boots (systemd)
       └─ docker.service starts
            └─ start_node.service  [/etc/systemd/system/start_node.service]
                 │  After=docker.service, User=pi, Type=simple, Restart=no
                 └─ /home/pi/mentorpi/start_node.sh
                      └─ [inside MentorPi Docker container]
                           └─ ros2 launch bringup bringup.launch.py
```

Verify on the robot:

```bash
systemctl is-enabled start_node.service   # → enabled
systemctl status start_node.service
cat /home/pi/mentorpi/start_node.sh
```

---

## Bringup fan-out diagram

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {
  'primaryColor': '#1e293b',
  'primaryTextColor': '#e2e8f0',
  'primaryBorderColor': '#7dd3fc',
  'lineColor': '#93c5fd',
  'secondaryColor': '#0f172a',
  'tertiaryColor': '#111827',
  'background': '#020817',
  'mainBkg': '#0f172a',
  'nodeBorder': '#7dd3fc',
  'clusterBkg': '#0f172a',
  'clusterBorder': '#93c5fd',
  'textColor': '#e2e8f0',
  'fontFamily': 'Arial',
  'fontSize': '14px'
}}}%%
flowchart LR
  classDef entry fill:#1f2937,stroke:#93c5fd,color:#f8fafc,stroke-width:1.5px;
  classDef launcher fill:#4f46e5,stroke:#a5b4fc,color:#eef2ff,stroke-width:1.5px;
  classDef core fill:#2563eb,stroke:#93c5fd,color:#eff6ff,stroke-width:1.5px;
  classDef sensor fill:#0f766e,stroke:#99f6e4,color:#ecfeff,stroke-width:1.5px;
  classDef service fill:#7c3aed,stroke:#c4b5fd,color:#f5f3ff,stroke-width:1.5px;

  A["systemd\nstart_node.service"]
  B["/home/pi/mentorpi/start_node.sh"]
  C["ros2 launch bringup\nbringup.launch.py"]

  A --> B --> C

  subgraph Core
    D[startup_check]
    E["ros_robot_controller\nSTM32 ↔ ROS 2 via UART\n→ /ros_robot_controller/imu_raw\nMotorsState → PWM"]
    F["odom_publisher\nmecanum kinematics\n136.8 / 144.6 / 65 mm\n→ /odom_raw @ 50 Hz"]
    G1["imu_calib\n/imu_raw → /imu_corrected"]
    G2["imu_filter\n/imu_corrected → /imu"]
    G["ekf_filter_node\n/odom_raw + /imu → /odom\nodom → base_footprint TF"]
    H["init_pose\ninit_pose.yaml + servo_config.yaml\n→ pwm_servo/set_state\nPWM servos to home position"]
    I["joy_node  /dev/input/js0\n+ joystick_control\n→ /controller/cmd_vel\n0.5 m/s · 2.0 rad/s"]
  end

  subgraph Sensors
    J["ascamera_node  HP60C\n/depth_cam/rgb/image_raw\n/depth_cam/depth/image_raw"]
    K["lidar driver\n$LIDAR_TYPE: MS200 | LD19\n→ /scan  LaserScan\nframe_id: lidar_frame"]
    L["robot_state_publisher\nURDF → /tf\nbase_footprint → lidar_frame\nbase_footprint → ascamera_link"]
  end

  subgraph Services
    M["rosbridge_websocket\nport 9090  ROS 2 ↔ JSON/WS"]
    N["web_video_server\nport 8080  image topics → MJPEG"]
    O["start_app\nline_follow · object_track\n/cmd_vel via rosbridge"]
  end

  C --> D
  C --> E
  C --> F
  C --> G1
  G1 --> G2
  G2 --> G
  F --> G
  C --> H
  C --> I
  C --> J
  C --> K
  C --> L
  C --> M
  C --> N
  C --> O

  class A,B entry;
  class C launcher;
  class D,E,F,G1,G2,G,H,I core;
  class J,K,L sensor;
  class M,N,O service;

  style Core fill:#0b1220,stroke:#93c5fd,stroke-width:1.2px,color:#e2e8f0;
  style Sensors fill:#0b1220,stroke:#99f6e4,stroke-width:1.2px,color:#e2e8f0;
  style Services fill:#0b1220,stroke:#c4b5fd,stroke-width:1.2px,color:#e2e8f0;
```

---

## Node reference

### Core — motion and state

These nodes must all be running for the robot to move and publish state.
If any Core node crashes, the chassis stops responding to commands.

| Node | Package | Subscribes | Publishes |
|---|---|---|---|
| `startup_check` | `bringup` | — | logs only |
| `ros_robot_controller` | `ros_robot_controller` | `ros_robot_controller/set_motor` (`MotorsState`) | `/ros_robot_controller/imu_raw` (`Imu`) |
| `odom_publisher` | `controller` | `controller/cmd_vel` (`Twist`) | `/odom_raw` (`Odometry`) |
| `imu_calib` | `imu_calib` | `/ros_robot_controller/imu_raw` | `/imu_corrected` (`Imu`) |
| `imu_filter` | `imu_complementary_filter` | `/imu_corrected` | `/imu` (`Imu`) |
| `ekf_filter_node` | `robot_localization` | `/odom_raw`, `/imu` | `/odom` (`Odometry`), `odom→base_footprint` TF |
| `init_pose` | `controller` | — | `ros_robot_controller/pwm_servo/set_state` (`SetPWMServoState`) |
| `joy_node` | `joy` | `/dev/input/js0` | `sensor_msgs/Joy` |
| `joystick_control` | `peripherals` | `sensor_msgs/Joy` | `/controller/cmd_vel` (`Twist`) |

Key parameters:
- mecanum model: wheelbase 136.8 mm, track width 144.6 mm, wheel diameter 65 mm
- joystick limits: linear max 0.5 m/s, angular max 2.0 rad/s
- `imu_filter` launch delay: 5 s (waits for `imu_calib` to stabilise)

### Sensors — perception

These nodes publish data from physical hardware.
If a sensor node crashes, the robot continues driving but loses spatial awareness.

| Node | Package | Publishes | TF frame |
|---|---|---|---|
| `ascamera_node` | `ascamera` | `/depth_cam/rgb/image_raw`, `/depth_cam/depth/image_raw`, `camera_info` | `ascamera_camera_link_0` |
| lidar driver | `peripherals` (wraps MS200 or LD19) | `/scan` (`LaserScan`) | `lidar_frame` |
| `robot_state_publisher` | `robot_state_publisher` | `/tf` static transforms | — |

Static TF published by `robot_state_publisher`:
- `base_footprint → lidar_frame`
- `base_footprint → ascamera_camera_link_0`

Lidar type is set by the `$LIDAR_TYPE` environment variable at container start (`MS200` or `LD19`).

### Services — remote access and app scenarios

These components can be stopped independently without affecting chassis control.

| Component | Protocol | Port | Purpose |
|---|---|---|---|
| `rosbridge_websocket` | JSON over WebSocket | 9090 | Exposes all ROS 2 topics and services to the mobile app and any browser client |
| `web_video_server` | MJPEG over HTTP | 8080 | Streams image topics; access via `http://<robot-ip>:8080/stream?topic=<topic>` |
| `start_app` nodes | ROS 2 | — | Line following, object tracking, and other scenario behaviours; receive commands via rosbridge, publish `/cmd_vel` |

---

## Confirmed minimum topic set after bringup

```bash
# Odometry pipeline
/ros_robot_controller/imu_raw   # raw IMU from STM32
/imu_corrected                  # after imu_calib
/imu                            # after imu_filter (complementary)
/odom_raw                       # mecanum kinematics only
/odom                           # EKF-fused, used by SLAM and navigation

# Servo initialisation
ros_robot_controller/pwm_servo/set_state  # PWM servos to home position (init_pose)

# Motion control
/controller/cmd_vel             # Twist from joystick or app
/ros_robot_controller/set_motor # MotorsState to STM32

# Sensors
/scan                           # LaserScan from lidar
/depth_cam/rgb/image_raw        # colour frames from HP60C
/depth_cam/depth/image_raw      # depth frames from HP60C

# Coordinate frames
/tf                             # odom→base_footprint, base_footprint→lidar_frame, etc.
/tf_static                      # base_footprint→ascamera_camera_link_0

# Remote access
rosbridge on port 9090
web_video_server on port 8080
```

---

## Quick verification commands

Run these from an external PC or the robot container to confirm bringup health.

```bash
# Node presence
ros2 node list | grep -E "ros_robot_controller|odom_publisher|ekf_filter|joy_node|joystick_control|ascamera|startup_check"

# Topic rates
ros2 topic hz /odom_raw    # expect ~50 Hz
ros2 topic hz /odom        # expect ~50 Hz
ros2 topic hz /scan        # expect ~10–15 Hz

# IMU pipeline
ros2 topic echo /ros_robot_controller/imu_raw --once
ros2 topic echo /imu --once

# TF tree (requires tf2_tools)
ros2 run tf2_tools view_frames

# Camera stream in browser
# http://<robot-ip>:8080
```
