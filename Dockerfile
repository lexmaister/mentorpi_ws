FROM osrf/ros:humble-desktop-full

SHELL ["/bin/bash", "-c"]

RUN apt update && apt install -y \
    git \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    build-essential \
    ros-humble-joint-state-publisher \
    ros-humble-joint-state-publisher-gui \
    ros-humble-robot-state-publisher \
    ros-humble-rviz2 \
    ros-humble-xacro \
    ros-humble-nav2-common \
    && rm -rf /var/lib/apt/lists/*

RUN rosdep init || true

RUN echo 'if [ -f /ws/scripts/dev_env.sh ]; then source /ws/scripts/dev_env.sh; fi' >> /root/.bashrc

WORKDIR /ws
CMD ["bash"]
