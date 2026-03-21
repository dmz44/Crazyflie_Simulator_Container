FROM osrf/ros:humble-desktop

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=graphics,utility,compute

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    curl \
    wget \
    vim \
    net-tools \
    python3-pip \
    lsb-release \
    gnupg \
    software-properties-common \
    x11-apps \
    && rm -rf /var/lib/apt/lists/*

# Gazebo
RUN curl -sSL https://packages.osrfoundation.org/gazebo.gpg -o /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null && \
    apt-get update && apt-get install -y gz-garden \
    && rm -rf /var/lib/apt/lists/*

# MuJoCo, Jinja2, etc.
RUN pip3 install --no-cache-dir \
    Jinja2 \
    mujoco \
    numpy \
    scipy \
    tomli

WORKDIR /root
RUN git clone https://github.com/gtfactslab/CrazySim.git --recursive

# Install crazyflie-lib-python (CFLib)
# Note: SETUPTOOLS_SCM_PRETEND_VERSION is required to bypass versioning issues
WORKDIR /root/CrazySim/crazyflie-lib-python
RUN SETUPTOOLS_SCM_PRETEND_VERSION=0.1.31 pip3 install -e .

# Install crazyflie-clients-python (CFClient for SITL)
WORKDIR /root
RUN git clone https://github.com/bitcraze/crazyflie-clients-python.git && \
    cd crazyflie-clients-python && \
    git checkout d649b66 && \
    pip3 install -e .

# Build Crazyflie Firmware for SITL (Software-In-The-Loop)
WORKDIR /root/CrazySim/crazyflie-firmware
RUN mkdir -p sitl_make/build && \
    cd sitl_make/build && \
    cmake .. && \
    make all

# Initialize Drone Models Submodule (Required for MuJoCo Assets)
WORKDIR /root/CrazySim/crazyflie-firmware
RUN git submodule update --init tools/crazyflie-simulation/simulator_files/mujoco/drone-models

# Environment & Shared Folder Setup
RUN mkdir -p /root/my_code

RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc

# Set the default working directory so the bash launch commands work immediately
WORKDIR /root/CrazySim/crazyflie-firmware

CMD ["bash"]
