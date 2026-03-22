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
    python-is-python3 \
    lsb-release \
    gnupg \
    software-properties-common \
    x11-apps \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --upgrade pip setuptools wheel

# Install Gazebo Garden (Required by CrazySim)
RUN curl -sSL https://packages.osrfoundation.org/gazebo.gpg -o /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/gazebo-stable.list > /dev/null && \
    apt-get update && apt-get install -y gz-garden \
    && rm -rf /var/lib/apt/lists/*

# Install Python Dependencies (MuJoCo, Jinja2, etc.)
RUN pip3 install --no-cache-dir \
    Jinja2 \
    mujoco \
    numpy \
    scipy \
    tomli

# Clone CrazySim Repository
WORKDIR /root
RUN git config --global url."https://github.com/".insteadOf git@github.com: && \
    git clone https://github.com/gtfactslab/CrazySim.git

WORKDIR /root/CrazySim
RUN git submodule update --init --recursive

# Install crazyflie-lib-python (CFLib)
WORKDIR /root/CrazySim
RUN if [ ! -f "crazyflie-lib-python/setup.py" ] && [ ! -f "crazyflie-lib-python/pyproject.toml" ]; then \
        rm -rf crazyflie-lib-python && \
        git clone https://github.com/bitcraze/crazyflie-lib-python.git; \
    fi

WORKDIR /root/CrazySim/crazyflie-lib-python
RUN SETUPTOOLS_SCM_PRETEND_VERSION=0.1.31 pip3 install .

# Install crazyflie-clients-python (CFClient for SITL)
WORKDIR /root
RUN git clone https://github.com/bitcraze/crazyflie-clients-python.git && \
    cd crazyflie-clients-python && \
    git checkout d649b66 && \
    pip3 install .

# Build Crazyflie Firmware for SITL (Software-In-The-Loop)
WORKDIR /root/CrazySim/crazyflie-firmware
RUN mkdir -p sitl_make/build && \
    cd sitl_make/build && \
    cmake .. && \
    make all

# Environment & Shared Folder Setup
RUN mkdir -p /root/my_code
RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc
WORKDIR /root/CrazySim/crazyflie-firmware

CMD ["bash"]
