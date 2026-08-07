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
3. [Using Ascamera package (ascamera)](docs/ascamera-guide.md)
4. [Run without full robot hardware](docs/working-without-robot.md)
5. [Debug from another PC](docs/debug-from-external-pc.md)
6. [Learning use-case playbooks](docs/learning-use-cases.md)
7. [Command cheat sheet](docs/command-cheat-sheet.md)
8. [Learning plan (8 weeks + extensions)](docs/learning-plan.md)
9. [Troubleshooting](docs/troubleshooting.md)

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
3. Run webcam-based perception examples from [Learning use-case playbooks](docs/learning-use-cases.md)

## Scope and assumptions

- Primary ROS distribution: ROS 2 Humble
- Primary OS: Linux host with Docker Engine + Docker Compose plugin
- GUI tools (RViz/OpenCV windows) assume X11 forwarding from host to container

For details, use the docs links above as the canonical source.