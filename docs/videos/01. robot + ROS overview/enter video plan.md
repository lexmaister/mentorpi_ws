# MentorPi ROS 2 Deep Dive — Entry Video Plan

## Video title + promise
**Working title:** *MentorPi (Hiwonder) ROS 2 Deep Dive — Robot Overview + System Architecture + Live Topic Debugging*

**Promise:** In this entry video, the viewer will (1) understand what the MentorPi robot is and what it can do as a real product, (2) understand the high-level ROS 2 architecture typically used on this class of mobile robot (and how the MentorPi stack maps onto it), and (3) connect from an external PC to observe live ROS 2 data (topics/TF/map) using standard tooling.

## Audience assumptions
Assume viewers know basic ROS concepts (nodes/topics) but may not be familiar with:

- mobile-robot coordinate frames and TF trees (`map`, `odom`, `base_link`, sensor frames)
- what “SLAM” and “Navigation” stacks look like as dataflow pipelines
- how vendor robots typically structure “bringup + drivers + applications”

## Runtime target + structure
Target **25–40 minutes**. This can be published as one longer episode, or split into **Part 1 / Part 2 / Part 3**.

Use clear YouTube chapters so the entry video becomes a reusable reference.

---

## Chapter 0 — Cold open (0:00–1:00)
Show the end result first: the robot moving plus live visualization on the laptop.

**Goal:** Make the series “payoff” visible immediately: the robot drives and you see the ROS 2 world update in real time.

**Suggested shots:**
- Robot moving in a small indoor space
- Laptop screen showing RViz (map + scan) or a live plot in PlotJuggler
- Terminal `ros2 topic list`

---

## Chapter 1 — Robot overview: what MentorPi is in reality (1:00–7:00)
Use the official MentorPi open-source repo as a neutral, factual overview: [Hiwonder/MentorPi](https://github.com/Hiwonder/MentorPi).

**What it is (high-level):**
MentorPi is a Raspberry Pi 5 based educational robot platform built for ROS 2 + AI robotics. It supports multiple chassis types (e.g., Ackermann, Mecanum, tank) and is commonly equipped with sensors like LiDAR and a depth camera, enabling SLAM-based mapping and autonomous navigation.

**What it can do out of the box (demo-friendly):**
- **Manual driving** (joystick / controller). This later becomes a great way to demonstrate `cmd_vel` and odometry changing live.
- **App-based control** (Android app with scenario-style demos). Frame this as: “Vendor apps often boil down to ROS messages, actions, or services behind a UI.”
- **Autonomous navigation using LiDAR** (mapping + localization + path planning + obstacle avoidance).
- Mention that there are also AI/vision features, but the initial goal of the series is **ROS 2 plumbing** first.

**Key teaching moment:** explain “features vs architecture.”
- Feature: “autonomous navigation.”
- Architecture: “LaserScan → SLAM → map → localization → planner → `cmd_vel` → motor driver.”

---

## Chapter 2 — What “ROS 2 implemented here” means (7:00–10:00)
Introduce the learning scaffold project: [lexmaister/mentorpi_ws](https://github.com/lexmaister/mentorpi_ws).

**Goal:** Define what you will analyze in this series so viewers know what “deep dive” means.

Explain that you will walk through:
- which packages and launch files bring the robot up
- which topics exist and who publishes/subscribes
- how driver data (scan/imu/encoders) becomes mapping and navigation
- how to debug systematically using:
  - RViz (spatial)
  - PlotJuggler (time-series)
  - CLI tools (`ros2 topic`, `ros2 node`, `ros2 tf`)

Set expectations: the workspace supports both:
- full robot workflows (when hardware is available)
- hardware-light learning workflows (Linux PC + Docker, optionally a webcam/depth camera)

---

## Chapter 3 — System architecture (10:00–20:00)
Use `docs/mentorpi-ros-architecture.md` from `mentorpi_ws` as the backbone, and extend it for newcomers.

**Recommended presentation pattern:**
1. Show one clean block diagram (slide).
2. Walk left-to-right through the layers.
3. For each layer, tie it to: (a) what node/package likely owns it, (b) what topics/frames should exist, (c) how to confirm using tools.

### 3A) Compute + processes layer
Explain the typical split in these robots:
- the main computer (Raspberry Pi) runs ROS 2 user-space nodes
- a microcontroller often handles low-level motor control / IO (and is bridged to ROS)

Emphasize: the external PC is just another ROS participant on the network.

### 3B) Hardware interface layer (drivers)
Explain “what drivers usually exist” on MentorPi-class robots:
- base/motor driver: accepts velocity commands (`cmd_vel`) and publishes odometry
- LiDAR driver: publishes `sensor_msgs/LaserScan`
- IMU driver: publishes `sensor_msgs/Imu`
- camera drivers: publish image topics (if enabled)

Promise for later videos: you’ll locate these in source (packages, launch files, params) and show how frame IDs are assigned.

### 3C) Robot state layer (TF + odom)
Do a short, beginner-friendly TF explanation:
- what `base_link` / `base_footprint` represent
- what `odom` represents (locally consistent motion)
- what `map` represents (globally referenced via SLAM/localization)

Explain the “symptoms” of common TF mistakes (jumping map, drifting robot model, wrong scan alignment), and why TF sanity checks come before tuning SLAM.

### 3D) SLAM + mapping layer
Explain the SLAM pipeline conceptually:
- inputs: LaserScan + odometry + TF
- outputs: `/map` plus a transform like `map → odom` (or equivalent)

Key message: “Mapping is a node producing a map and a transform; it’s not magic.”

### 3E) Navigation layer
Keep it conceptual in the entry video:
- localization consumes map + scan + odom
- planning consumes a goal + costmaps → outputs velocity commands

Tease: later videos will identify the exact stack/config used here (Nav2 vs vendor equivalents), and how to trace command flow end-to-end.

---

## Chapter 4 — Live example: observe ROS 2 from an external PC (20:00–33:00)
Use `docs/debug-from-external-pc.md` from `mentorpi_ws` as the step-by-step demo.

**Narrative arc:**
1. “Robot is running; we won’t guess what’s happening.”
2. Connect as a ROS 2 participant from another PC.
3. Prove discovery with node/topic listing.
4. Visualize spatial data with RViz.
5. Visualize time-series with PlotJuggler.
6. Validate one loop: joystick movement → `cmd_vel` changes → odometry responds.

### Demo checklist (what to show on screen)
Keep this tight and systematic so it’s repeatable:

**Network + discovery**
- Ensure robot + PC are on the same network (LAN/AP setup can be its own later episode).
- Apply the ROS 2 network settings from the guide (domain ID, RMW, etc. as required).

**CLI “proof” steps**
Show a few commands and explain why each matters:
- `ros2 topic list` (proves discovery)
- `ros2 node list` (proves graph)
- `ros2 topic echo /scan` (proves LiDAR data is flowing)
- `ros2 topic hz /scan` (quick quality check)
- `ros2 topic echo /cmd_vel` while driving (proves command channel)
- `ros2 topic echo /odom` (or equivalent) while driving (proves motion feedback)

**RViz**
Open RViz and add displays:
- TF
- LaserScan
- Map (if SLAM is running)
- RobotModel (if URDF is available)

**PlotJuggler**
Open PlotJuggler and plot:
- linear velocity / angular velocity from odom
- IMU yaw rate (if available)

**Validation moment (important on camera):**
Drive forward for 2–3 seconds and say: “This is the minimum viable proof that ROS is alive end-to-end: command → motion → feedback → visualization.”

---

## Chapter 5 — Wrap-up + next episodes (33:00–36:00)
End by clearly announcing what comes next:

- Next: *From architecture to code*: where launch files live, what starts at boot, bringup walkthrough.
- Next: TF + topics sanity checklist (scan/odom/tf) before touching SLAM parameters.
- Next: SLAM deep dive (algorithm choice, parameters, failure modes).
- Next: Navigation deep dive (costmaps, planners, `cmd_vel`, safety).

Optional CTA: ask viewers to comment their chassis type (Ackermann/Mecanum/tank) and sensor set, because TF/configs can differ.

---

## Preferred visual materials (prepare before recording)

### Slides / diagrams
- **Architecture block diagram** (Sensors → Drivers → TF/Odom → SLAM → Nav → `cmd_vel` → Base).
- **ROS 2 graph view** (nodes and topic connections). If you can’t generate a graph automatically, a simplified “topics tree” slide works well.
- **TF frame tree** (at least `map`, `odom`, `base_link`, LiDAR frame). A screenshot from RViz TF display is perfect.

### Screen recordings
- Terminal capture of:
  - `ros2 node list`
  - `ros2 topic list`
  - `ros2 topic echo /scan`
  - `ros2 topic echo /cmd_vel`
  - `ros2 topic echo /odom`
- RViz capture showing:
  - LaserScan aligning with RobotModel
  - Map updating (if SLAM running)
- PlotJuggler capture showing:
  - velocity/IMU traces while you drive

### Physical b-roll
- Close-ups of:
  - LiDAR in operation
  - depth camera module (if installed)
  - chassis and wheel type
  - Raspberry Pi / internal electronics (if accessible)
- A short “feature demo” montage:
  - joystick drive
  - app control (one scenario)
  - autonomous nav clip (brief teaser)
