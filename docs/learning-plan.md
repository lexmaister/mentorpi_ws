# Learning Plan (8 Weeks)

This plan is a progressive path from workspace basics to full robot workflows.

## 1. Plan goals

- become fluent with MentorPi ROS package structure
- run useful demos without full hardware first
- transition safely to robot-hardware-dependent stacks
- build confidence in debugging and extension workflows

## 2. Prerequisites

Before Week 1:

- Linux host with Docker working
- this workspace cloned
- container can start and shell entry works with `./scripts/up.sh`

## 3. Week-by-week roadmap

### Week 1: Workspace and Docker fundamentals

Objectives:

- understand repository structure
- run container and build workspace
- inspect ROS graph basics

Deliverables:

- successful `./scripts/provision_ascamera_libs.sh` then `colcon build --symlink-install`
- notes of key packages and their role

### Week 2: Robot model and TF literacy

Objectives:

- run `mentorpi_description` visualization
- read TF tree and frame naming
- map which packages depend on frame conventions

Deliverables:

- RViz screenshot set for major frames
- short TF/frame glossary for yourself

### Week 3: USB webcam integration

Objectives:

- start `peripherals usb_cam.launch.py`
- validate image and camera-info topics
- debug camera parameter issues (device, pixel format)

Deliverables:

- stable webcam stream on `/ascamera/camera_publisher/rgb0/image`

### Week 4: Perception with YOLO

Objectives:

- run `yolov5_ros2` on webcam stream
- inspect detection messages and rates
- profile CPU impact and tune image size/frame rate

Deliverables:

- reproducible YOLO runbook with command set and expected topics

### Week 5: Example package deep dive

Objectives:

- run image-only example nodes
- identify which examples require hardware controllers
- document launch dependency patterns

Deliverables:

- table of examples: runnable on PC vs requires robot

### Week 6: Ascamera and depth camera path

Objectives:

- understand `ascamera` package architecture
- run with real depth/stereo camera when available
- compare ascamera vs usb_cam behavior and topic compatibility

Deliverables:

- driver notes: required environment, dependencies, common failures

### Week 7: Distributed debugging (external PC)

Objectives:

- run robot-side stack and monitor from another machine
- validate ROS networking setup and topic discovery
- run RViz/debug tooling remotely

Deliverables:

- external-debug checklist for your local network

### Week 8: Transition to full robot autonomy stack

Objectives:

- integrate hardware-dependent components gradually
- run calibration, then SLAM, then navigation
- capture blocking issues and mitigations

Deliverables:

- phased bringup document tailored to your robot setup

## 4. Optional extension tracks (Weeks 9-12)

### Track A: Multi-robot

- namespace strategy
- host/master conventions
- follower and TF validation

### Track B: AI and large-model workflows

- `large_models` package walkthrough
- speech/vision integration points
- safe fallback behavior when model backends are unavailable

### Track C: Reliability engineering

- startup scripts and health checks
- topic watchdogs and restart strategy
- repeatability and reproducible builds

## 5. Weekly cadence template

Use this template every week:

1. Study: 1-2 short docs/code sessions
2. Run: at least one practical launch workflow
3. Debug: solve one failure intentionally
4. Record: capture commands, errors, fixes
5. Review: update your own runbook

## 6. Exit criteria

You are ready for production-like robot experiments when:

- you can diagnose package/launch failures quickly
- you can run perception pipelines reliably in Docker
- you understand hardware-required boundaries
- you can debug robot topics remotely from another PC
- you can bring up SLAM/navigation with known prerequisites

## 7. Suggested companion docs

- [Docker setup and daily workflow](getting-started-docker.md)
- [Command cheat sheet](command-cheat-sheet.md)
- [Run without full robot hardware](working-without-robot.md)
- [Ascamera guide](ascamera-guide.md)
- [Troubleshooting](troubleshooting.md)
