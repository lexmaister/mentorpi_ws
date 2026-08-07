# Learning Use-Case Playbooks

This guide adds practical learning tracks so you can study MentorPi progressively.

## 1. Use case A: ROS 2 workspace fundamentals

Goal: understand packages, launches, and topic graph.

Steps:

1. Build workspace in Docker.
2. List packages and inspect dependency graph.
3. Launch a simple visualization and inspect topics/nodes.

Commands:

```bash
ros2 pkg list
ros2 node list
ros2 topic list
```

What you learn:

- package boundaries
- launch behavior
- ROS graph debugging

## 2. Use case B: Robot model and TF understanding

Goal: understand robot frames and state publishing.

Steps:

1. Launch `mentorpi_description` display.
2. Inspect TF tree and fixed frames in RViz.
3. Validate frame naming conventions for downstream stacks.

Command:

```bash
ros2 launch mentorpi_description display.launch.py
```

What you learn:

- URDF-driven model visualization
- TF relationships used by navigation/perception

## 3. Use case C: Camera pipeline with USB webcam

Goal: emulate robot RGB stream without robot hardware.

Steps:

1. Start `usb_cam.launch.py`.
2. Confirm remapped image topics under `/ascamera/...`.
3. Run image consumer nodes from examples.

Core commands:

```bash
ros2 launch peripherals usb_cam.launch.py
ros2 topic hz /ascamera/camera_publisher/rgb0/image
```

What you learn:

- topic remapping strategy
- image transport and camera-info usage

## 4. Use case D: YOLO perception pipeline

Goal: run object detection integrated with ROS topics.

Steps:

1. Ensure image source exists (`usb_cam` or `ascamera`).
2. Run `yolov5_ros2` detector on CPU.
3. Observe detection outputs and message flow.

Command:

```bash
ros2 run yolov5_ros2 yolo_detect --ros-args -p device:=cpu -p image_topic:=/ascamera/camera_publisher/rgb0/image
```

What you learn:

- model inference in ROS node
- integration of perception topics into behavior nodes

## 5. Use case E: Depth camera driver understanding (`ascamera`)

Goal: understand vendor driver integration and constraints.

Steps:

1. Build workspace with `ascamera` enabled.
2. Launch `ascamera` and inspect camera topics.
3. Compare behavior against USB fallback mode.

What you learn:

- vendor native library dependency management
- device mapping and permissions in Docker

## 6. Use case F: Remote debugging from external PC

Goal: inspect robot runtime from another Linux machine.

Steps:

1. Start robot-side SLAM/perception.
2. Set ROS networking env on external PC.
3. Run RViz and diagnostics remotely.

See full guide: [Debug MentorPi From Another PC](debug-from-external-pc.md)

What you learn:

- distributed ROS 2 debugging
- network/domain troubleshooting

## 7. Use case G: Prepare for full navigation stack

Goal: reduce risk before hardware run.

Preparation checklist:

- TF frame assumptions validated in RViz
- camera pipeline stable
- topic names and QoS expectations documented
- launch parameters understood

Then move to robot hardware for:

- lidar + odometry + localization integration
- mapping and autonomous path execution

## 8. Suggested study order

1. Use case A
2. Use case B
3. Use case C
4. Use case D
5. Use case F
6. Use case E
7. Use case G

This order maximizes progress without requiring full hardware early.