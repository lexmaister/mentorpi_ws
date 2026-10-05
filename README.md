# MentorPi ROS 2 Learning Workspace

This repository is a Linux-first learning workspace for developing, testing, and understanding the MentorPi ROS 2 stack with Docker.

It is designed for two modes:

- full robot workflows when MentorPi hardware is available
- hardware-light workflows for learning on a regular Linux PC with only Docker, and optionally a USB webcam or depth camera

The workspace includes:

- ROS 2 packages from MentorPi under `src/MentorPi`
- vendor depth camera package `src/ascamera`
- containerized development with `compose.yml` and `Dockerfile`
- practical guides in `docs/`

## Documentation map

Start here and then open the guides below:

1. [Docker setup and daily workflow](docs/getting-started-docker.md)
2. [MentorPi ROS system architecture](docs/mentorpi-ros-architecture.md)
3. [Bringup reference — boot chain, node table, topic set](docs/bringup-reference.md)
4. [Using Ascamera package (ascamera)](docs/ascamera-guide.md)
5. [Run without full robot hardware](docs/working-without-robot.md)
6. [Command cheat sheet](docs/command-cheat-sheet.md)
7. [Troubleshooting](docs/troubleshooting.md)

Remote debugging from a separate PC is covered directly in this README, see [Debugging from a separate PC](#debugging-from-a-separate-pc) below.

## Quick start (Linux + Docker)

Populate MentorPi source first (this repository may keep `src/MentorPi` empty by design):

```bash
git clone --branch MentorPi-M1 https://github.com/Hiwonder/MentorPi.git src/MentorPi
```

Verify required folders exist:

```bash
ls src/MentorPi
```

From the repository root:

```bash
xhost +local:docker
docker compose build
./scripts/provision_ascamera_libs.sh
./scripts/up.sh
```

Direct alternative:

```bash
./scripts/provision_ascamera_libs.sh
docker compose up -d
docker compose exec mentorpi_dev bash
```

Inside the container:

```bash
cd /ws
colcon build --symlink-install
```

After you open a container shell, it is preconfigured by `scripts/dev_env.sh` (ROS setup + workspace setup + default MentorPi env vars).

Notes:

- This project uses `compose.yml` (not `docker-compose.yml`).
- The host path can be any location on your Linux machine.
- `src/MentorPi` is expected to come from an external MentorPi source clone.
- `src/` is bind-mounted from host; `scripts/` (including `scripts/.typerc`) is mounted for environment setup.
- `build/`, `install/`, and `log/` are persistent Docker volumes.

## Repository layout

```text
mentorpi_ws/
|- compose.yml
|- Dockerfile
|- scripts/
|  |- up.sh
|  |- dev_env.sh
|  |- rebuild.sh
|  |- camera_doctor.sh
|  |- provision_ascamera_libs.sh
|  |- .typerc
|  |- run_ascamera_node.sh
|- docs/
|- src/
   |- MentorPi/
   |- ascamera/
```

## What to run first for learning

If you want a fast start without robot hardware:

1. Follow [Docker setup and daily workflow](docs/getting-started-docker.md)
2. Run the robot model visualization from [Run without full robot hardware](docs/working-without-robot.md)

## Scope and assumptions

- Primary ROS distribution: ROS 2 Humble
- Primary OS: Linux host with Docker Engine + Docker Compose plugin
- GUI tools (RViz/OpenCV windows) assume X11 forwarding from host to container

For details, use the docs links above as the canonical source.

## Debugging from a separate PC

Use a second Linux PC to run compute/GUI-heavy tools (RViz, rqt, browser dashboards) while the robot container produces the data. The container uses `network_mode: host`, so these settings apply equally to the container and to a bare-metal ROS install on the laptop.

### 1. Required environment on both the robot container and the external laptop

```bash
export ROS_DOMAIN_ID=0
export ROS_LOCALHOST_ONLY=0
export ROS_AUTOMATIC_DISCOVERY_RANGE=SUBNET
export ROS_STATIC_PEERS="<ROBOT_IP>;<PC_IP>"   # robot IP;laptop IP (adjust to your network)
```

- `ROS_DOMAIN_ID` must match on both sides.
- `ROS_LOCALHOST_ONLY=0` is required or nodes only see themselves.
- `ROS_AUTOMATIC_DISCOVERY_RANGE=SUBNET` and `ROS_STATIC_PEERS` were found necessary in practice to get reliable discovery across two machines beyond default multicast discovery — set both, listing the IPs of every participant (robot and laptop), separated by `;`.

### 2. Making the settings persistent

For better DDS discovery:

  1. Run dev container and robot
  2. Restart ROS stack on robot while dev container is running

#### On the PC (dev container)

`compose.yml` already has `ROS_AUTOMATIC_DISCOVERY_RANGE` and `ROS_STATIC_PEERS` in the `environment:` section. Adjust the IPs to match your network, then recreate the container:

```bash
docker compose down && docker compose up -d
```

#### On the robot

The robot container sources `/home/pi/docker/tmp/.typerc` on every shell startup. Edit that file to bake in the discovery variables so they survive restarts.

1. **Back up the existing file** before editing:

   ```bash
   cp /home/pi/docker/tmp/.typerc /home/pi/docker/tmp/.typerc.bak
   ```

2. **Copy the updated `scripts/.typerc`** from this repository to the robot's shared directory `/home/pi/docker/tmp/.typerc`, then set your network IPs:

   ```bash
   # Run on the robot host (outside the container)
   nano /home/pi/docker/tmp/.typerc      # update ROS_STATIC_PEERS to your robot and PC IPs
   ```

3. **Restart the ROS stack** so the new environment takes effect:

   ```bash
   /home/pi/mentorpi/start_node.sh > /dev/null 2>&1 &
   ```

4. **Enter the container** after beep signal from robot and verify the variables appear in the startup banner:

   ```bash
   /home/pi/enter_ros.sh
   # Confirm STATIC_PEERS shows your robot and PC IPs
   ```

### 3. Verify connectivity and validate

**On both machines** — confirm the variables are active:

```bash
echo "$ROS_DOMAIN_ID $ROS_LOCALHOST_ONLY $ROS_AUTOMATIC_DISCOVERY_RANGE $ROS_STATIC_PEERS"
```

**On the robot** — note the baseline topic count:

```bash
ros2 topic list | wc -l
# returns 49
```

**On the PC** — the same command should return a matching count (topics are shared across machines) - try twice if the first returned count doesn't match the robot's number:

```bash
ros2 topic list | wc -l
# also should return 49
```

If the counts match, both sides see the robot's topics. Confirm odometry is flowing from the robot to the PC:

```bash
ros2 topic echo /odom_raw
```

If `ros2 topic list` returns only 1–3 topics (e.g. `/parameter_events`, `/rosout`), discovery is not working — revisit the settings in section 2.

### 4. Browser access to robot ports (no ROS install needed on the client)

Bringup also exposes two HTTP/WebSocket services directly on the robot, reachable from any browser on the same network — no ROS environment variables required:

- `http://<robot-ip>:8080` — `web_video_server`, MJPEG image streaming. Specific topic: `http://<robot-ip>:8080/stream?topic=/depth_cam/rgb/image_raw`.
- `<robot-ip>:9090` — `rosbridge_websocket`, JSON-over-WebSocket access to all topics/services (used by the mobile app, or any `roslibjs` client).

### 5. Common failure modes

- `ROS_DOMAIN_ID` mismatch between robot and laptop.
- Missing `ROS_STATIC_PEERS`/`ROS_AUTOMATIC_DISCOVERY_RANGE` — multicast discovery alone can silently fail across some routers/subnets.
- Firewall blocking UDP discovery traffic or ports 8080/9090.
- Different ROS distros with incompatible message definitions.
- Robot stack not actually publishing the expected topics — check with `ros2 topic hz` on the robot first.