# MentorPi ROS System Architecture

This document is the workspace-level architecture reference for MentorPi ROS 2 packages.

## 1. High-level view

MentorPi is organized as layered ROS 2 subsystems:

1. hardware and sensors
2. shared interfaces
3. startup and calibration
4. autonomy (SLAM/navigation/multi)
5. application and AI behaviors
6. simulation/description

Typical runtime flow:

1. hardware drivers publish base state and sensors
2. interface packages define shared messages/services
3. bringup launches baseline robot runtime
4. autonomy packages consume state + sensor data
5. app/example/AI packages implement visible behaviors

## 2. Package map

Core package groups in this workspace:

- Hardware layer:
  - `src/MentorPi/driver`
  - `src/MentorPi/peripherals`
  - `src/ascamera`
- Interface layer:
  - `src/MentorPi/interfaces`
  - `src/MentorPi/driver/ros_robot_controller_msgs`
  - `src/MentorPi/large_models_msgs`
- Startup and calibration:
  - `src/MentorPi/bringup`
  - `src/MentorPi/calibration`
- Autonomy:
  - `src/MentorPi/slam`
  - `src/MentorPi/navigation`
  - `src/MentorPi/multi`
- Applications and AI:
  - `src/MentorPi/app`
  - `src/MentorPi/example`
  - `src/MentorPi/large_models`
  - `src/MentorPi/yolov5_ros2`
- Simulation/model:
  - `src/MentorPi/simulations/mentorpi_description`

## 3. Responsibilities by major package

### driver

Low-level robot control and bridge to controller board.

- `controller`: Python-side control workflows
- `ros_robot_controller`: ROS interface runtime
- `ros_robot_controller_msgs`: custom messages/services
- `sdk`: helper SDK components

### peripherals

External devices and operator input.

- joystick and keyboard teleop
- IMU and filtering helpers
- camera and lidar launch wrappers

### ascamera

Vendor depth-camera package (Ascamera/HP60 family).

- C++ node and launch files
- vendor libraries
- configuration files

### bringup

System startup composition and baseline runtime orchestration.

### calibration

Linear/angular calibration and tuning tools.

### slam

Mapping and localization workflows (including RViz helpers).

### navigation

Goal-driven autonomous navigation and integration launches.

### multi

Multi-robot coordination, TF and follower workflows.

### app/example

Task-level behaviors and demos.

### large_models and large_models_msgs

AI-driven behaviors and their interface contracts.

### yolov5_ros2

Object-detection integration and ROS topic publishing.

### mentorpi_description

URDF/TF description for visualization and simulation usage.

## 4. Integration patterns

Common system compositions:

1. base robot operation:
   - `bringup` + `driver` + `peripherals`
2. perception + behavior:
   - `peripherals` or `ascamera` + `app`/`example`/`yolov5_ros2`
3. autonomy:
   - `calibration` -> `slam` -> `navigation`
4. multi-robot:
   - baseline stack + `multi`

## 5. Hardware dependency categories

- Mostly hardware-required:
  - `driver`, `bringup`, many `app` and motion-centric examples
- Hardware-optional with substitutions:
  - `peripherals` camera flows via USB webcam
  - selected image-only `example` nodes
  - `yolov5_ros2` on webcam/image topics
- PC-only friendly:
  - `mentorpi_description` visualization
  - ROS graph/topic debugging

## 6. Development recommendation

When adding new functionality, place it in the highest valid layer:

- hardware specifics in driver/peripherals/ascamera
- cross-package messages in interfaces packages
- behavior logic in app/example
- autonomy logic in slam/navigation/multi

This keeps dependencies clean and helps maintain testability without full robot hardware.