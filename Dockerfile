FROM osrf/ros:humble-desktop-full

SHELL ["/bin/bash", "-c"]

RUN apt update && apt install -y \
    software-properties-common \
    && add-apt-repository -y ppa:maveonair/helix-editor

RUN apt update && apt install -y \
    git \
    python3-pip \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-vcstool \
    build-essential \
    helix \
    ros-humble-usb-cam \
    ros-humble-joint-state-publisher \
    ros-humble-joint-state-publisher-gui \
    ros-humble-robot-state-publisher \
    ros-humble-rviz2 \
    ros-humble-plotjuggler-ros \
    ros-humble-xacro \
    ros-humble-nav2-common \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --no-cache-dir "numpy<2" "mediapipe==0.10.14"

RUN rosdep init || true

RUN echo 'if [ -f /ws/scripts/dev_env.sh ]; then source /ws/scripts/dev_env.sh; fi' >> /root/.bashrc

WORKDIR /ws
CMD ["bash"]
