# Project Central Github For Crazyflie Digital Twin

**Authors:** Minhyuk Park 

## Project Snapshot

This project develops a high-fidelity digital twin of the Ingram Hall Makerspace that enables safe simulation, training, and validated deployment of autonomous Crazyflie nano-drones for digital twin-enabled manufacturing applications such as equipment inspection, real-time monitoring, and cooperative transport.

Why it matters: This framework gives any Makerspace users at Texas State a sandbox to safely develop, train, and validate complex autonomous MAV behaviors for emerging applications. 

Key Learning Point: Parameters that govern MAV flight behaviors must be calibrated for optimal performance, even with correct logic.

## Project Deliverables

30-second summary video: <https://drive.google.com/file/d/1J_6d2As1bpskjAR-dplAZ2sL2opRp90D/view?usp=sharing>

Key Visuals: <https://docs.google.com/presentation/d/115gO2i_GZikG7vR0Zpoc2FcxGz4xHEBf/edit?usp=sharing&ouid=112415346817157075865&rtpof=true&sd=true>

Report: <https://drive.google.com/file/d/1xDkta0cFnp7d-JHvZ3_LSOG5bLhXQB2h/view?usp=sharing>

Poster: <https://docs.google.com/presentation/d/1YkmZNyvzgnY8wjxot852Uk8dMgz-Reg5/edit?usp=sharing&ouid=112415346817157075865&rtpof=true&sd=true>

Poster Day Video: <https://drive.google.com/file/d/1EusbUSjB1M_f65jKXuMQH5INTkOOd7pK/view?usp=sharing>

## Introduction

This repository will direct you to various resources I have created for the Makerspace Crazyflie Digital Twin Project.

### Repositories related to this project:

ZED Ply to obj conversion: <https://github.com/dmz44/zed_camera_docker>

How to get the AI deck to work properly: <https://github.com/dmz44/aideck_fixes>

Crazyswarm Lidar SLAM container: <https://github.com/dmz44/Crazyswarm_Rangefinder_SLAM>

Pybullet Simulator for RL training <https://github.com/dmz44/Pybullet_Docker>

Crazysim Simulator (Internal Testing In Progress): <https://github.com/dmz44/Crazyflie_Simulator_Container>

### Key Outcomes:

- Assembled Crazyflie 2.1 system with Lighthouse Localization tripods, configured for autonomous tasks
- Containerized PyBullet + OpenAI Gym digital twin of the Makerspace 
- GitHub repository with Crazyflie flight software, trained RL models, and mapping pipelines

### Accomplishments:

- Development of Dual-mapping architecture (offline ZED mesh + online Lidar occupancy grid) demonstrated
- PPO reinforcement learning pipeline validated for waypoint navigation and obstacle avoidance
- Sim-to-real transfer pipeline established with minimal modification to deployed policies
- Applications demonstrated in simulation: facility monitoring, cooperative load transport, object interaction

### Next Steps / Future Development:

- More comprehensive RL policy testing and tuning cycles
- Development of more sophisticated Digital Twin-Enabled Manufacturing Workflows
- Expansion to cooperative multi-agent drone scenarios
- Integration with the broader Texas State intelligent robotics research testbed

-----------------------------------------------------------------------------------

## Crazysim Introduction

This repository will teach you how to deploy the Crazysim simulator in a Docker container environment for testing cflib scripts in the simulator. 

Credits: Crazysim <https://github.com/gtfactslab/CrazySim>

# Part 1 - Environment Setup

# How to Install Required Software on Your Own PC 

The hardware requirement is hardware capable of supporting the Ubuntu 24 Operating System with a relatively modern Nvidia GPU. While Docker is designed to allow portability across Operating Systems, other operating system configurations might need some custom configuration. For example, if you are using windows 11, you would need to configure WSL2 and windows docker engine, along with additional downloads within WSL2 to make this work.

## Preparing Your Own PC for Docker Installation

1) **Install Ubuntu 24.04 LTS (64bit, Desktop)**.

```bash
<https://ubuntu.com/download/desktop>
```

2) **Install essential software on your Host PC by executing the following command on the Host Terminal Window**:

```bash
sudo apt -y install vim
sudo apt -y install net-tools
sudo apt -y install openssh-server
sudo apt -y install curl
```

You may want to remap the shortcut keys of Copy and Paste in your terminal.

3) **Set up Network**:

Set up wifi connection settings to your internet, such as TXST-Bobcats wifi and Local Wifi connection for Small_Blue_Wifi (for the local network environment for Turtlebot 3’s Single Board Computer)

Run ifconfig to see the IP of remote-pc while being connected to Small_Blue_Wifi. Remember the IP as IP_OF_REMOTE_PC.

4) **Update Ubuntu software for the Host PC by executing the following on the Host's Terminal Window**:

```bash
sudo apt-get update
sudo apt-get upgrade
```

Now, we need to set up the Docker engine on your host machine. Follow these steps to install Docker from the official repository.
    [<https://docs.docker.com/engine/install/ubuntu//> ](https://docs.docker.com/engine/install/ubuntu/)

5) **Remove conflicting packages (if any) by executing the following on the Host's Terminal Window:**

```bash
sudo apt-get remove docker docker-engine docker.io containerd runc
```

6) **Set up the repository by executing the following on the Host's Terminal Window:**

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

```
7) **Add the repository to Apt sources by executing the following on the Host's Terminal Window:**

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

```

8) **Install Docker packages by executing the following on the Host's Terminal Window:**

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

```


9) **Manage Docker as a non-root user by executing the following on the Host's Terminal Window:**
To avoid typing `sudo` for every Docker command, add your user to the Docker group:

```bash
sudo usermod -aG docker $USER
newgrp docker

```


10) **Verify Installation by executing the following on the Host's Terminal Window:** If you are getting permission errors, you might need to reboot your computer after adding your user to the Docker group. Alternatively, for a temporary solution, you can add sudo in front of all the commands for Docker. 

```bash
docker run hello-world

```

11) **Configure the repository for NVIDIA Container Toolkit by executing the following on the Host's Terminal Window:**
To allow the Docker container to access your GPU (essential for Gazebo simulation and AI tasks), you must install the NVIDIA Container Toolkit.

```bash
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

```

12) **Install the NVIDIA toolkit by executing the following on the Host's Terminal Window:**
```bash
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

```

13) **Configure Docker runtime and restart by executing the following on the Host's Terminal Window:**
```bash
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

```

# Part 2: Container Setup and How to Use Docker

## Container Setup

1. **Clone the Docker repository:**
```bash
mkdir -p ~/crazyflie_docker
cd ~/crazyflie_docker
mkdir -p my_code
git clone https://github.com/dmz44/Crazyflie_Simulator_Container.git
cp Crazyflie_Simulator_Container/Dockerfile Dockerfile
cp Crazyflie_Simulator_Container/docker-compose.yml docker-compose.yml
```

2. **Build and Start the Container:**
We have provided a `docker-compose.yml` file that automates the build process and sets up the necessary volume mappings (shared folders) and display settings.

**We recommend doing this when you find weird behaviors**

```bash
# Build and start the container in detached mode
cd ~/crazyflie_docker
HOST_UID=$(id -u) USER_HOME=$HOME docker compose up -d --build

```

*Note: This process may take a long time depending on your internet speed as it downloads ROS 2 Humble and builds the simulation packages.*

## How to use Docker

You should start the container itself every time you reboot the computer. Please refer to **Start the Container** step below.

Once the container is running, you can enter it and run the simulation examples. You can enter it in multiple terminal windows to get multiple terminal windows of the container.

*For those not familiar with Docker, you need to enter the container and use the container's terminal/shell, or the software given in milestones will not run!*

1. **Enable GUI Permissions:**
Since the simulation runs inside Docker but displays on your host screen, you need to allow local connections to the X server. This needs to be done every boot:
```bash
xhost +local:root

```
*You need to run this command again if you restart your computer.*

2. **Start the Container. You only need to do it once every boot unless you stop the environment by composing down:**

```bash
# Build and start the container in detached mode without building.
cd ~/crazyflie_docker
HOST_UID=$(id -u) USER_HOME=$HOME docker compose up -d 

```

3. **Enter the Container:**
```bash
docker exec -it remote_pc_humble bash

```

4. **Stopping the Environment:**
When you are finished, you can stop the container from your host terminal:
```bash
docker compose down

```
5. **Critical Concept: The Container is Temporary (Immutable)**

It is vital to understand that a Docker container is **ephemeral**. This means it resets to its original "factory settings" every time you delete it (via `docker compose down`) and restart it.

* **What is lost:** If you run `sudo apt install <package>` or create a file inside the container's home folder (e.g., `/root/`), those changes **will vanish** when the container is stopped.
* **What is safe:** Only files stored in the **Shared Folder** (see Section 8) are safe.
* **Temporary Testing:** It is perfectly fine to install a package manually or edit a system config file inside the container to test a fix. Just remember that you must repeat that step next time, or make the change permanent (see Section 9).

6. **Restarting the Container**

If you just want to "pause" your work without losing the container's temporary state, you can use `docker compose stop` and `docker compose start`. However, for this course, we generally recommend fully shutting down (`down`) to clear simulation glitches.

7. **The Shared Folder: Where to Save Your Code**

To prevent losing your homework, we use a feature called **Volume Mapping** (Shared Folders). This creates a direct "tunnel" between a specific folder on your real computer (Host) and a folder inside the Docker container.

* **On your Host:** The folder is `~/crazyflie_docker/my_code`.
* **Inside Docker:** The folder is mapped to `~/my_code`.

**How to use it:**

1) Create your Python scripts **inside this folder**.
2) If you edit a file in this folder on your laptop (using VS Code, Sublime, etc.), the change appears **instantly** inside the Docker container.
3) Even if you delete the container completely, files in this folder remain safe on your laptop.

8. **Advanced: Modifying the Docker Image (Rebuilding)**

Let's say you need a new system library (e.g., `scipy` or a new `apt` package) permanently on your Docker Image. We can rebuild the Docker image by the following:

1. **Edit the Dockerfile:** Open the `Dockerfile` in your host text editor. Add the installation command (e.g., `RUN pip3 install scipy`) in the appropriate section.
2. **Rebuild the Container:** You must tell Docker to rebuild the image based on your changes. Run the following command from your host terminal:

```bash
docker compose up -d --build

```

The `--build` flag forces Docker to read the `Dockerfile` again and install the new software.

# Part 3 - How to use Crazysim for cflib Simulation

This section describes how to use Crazysim for cflib simulation.

This manual assumes you have completed Part 1 and 2 on setting up your PC. Please enter the container and work within the container.

Then follow the instructions for your chosen backend below.


---

## Global Simulator Information

You need to execute 1. and 2. every boot.

1. **Enable GUI Permissions:**
Since the simulation runs inside Docker but displays on your host screen, you need to allow local connections to the X server. This needs to be done every boot:
```bash
xhost +local:root

```
*You need to run this command again if you restart your computer.*

2. **Start the Container. You only need to do it once every boot unless you stop the environment by composing down:**

```bash
# Build and start the container in detached mode without building.
cd ~/crazyflie_docker
HOST_UID=$(id -u) USER_HOME=$HOME docker compose up -d 

```
And execute all bash commands within the container.

3. **Enter the Container:**
```bash
docker exec -it remote_pc_humble bash

```

Note that you need to place your script in my_code folder. The crazyflie_docker/my_code in your host operating system is mapped to ~/my_code in the docker container.

Connect with CFLib using URI `udp://127.0.0.1:19850`. For drone swarms increment the port for each additional drone.

You can also test a single crazyflie using the cfclient if you installed it from the crazyflie-clients-python section. Click on the SITL checkbox, scan, and connect.

---

## Simulation Backend: Gazebo


### Gazebo Models

| Model | Description |
| --- | --- |
| crazyflie | The default Crazyflie 2.1. |
| crazyflie_thrust_upgrade | The Crazyflie 2.1 with thrust upgrade bundle ([cf2x_T350](https://github.com/utiasDSL/drone-models) parameters). |

#### Option 1: Single agent
```bash
bash tools/crazyflie-simulation/simulator_files/gazebo/launch/sitl_singleagent.sh -m crazyflie -x 0 -y 0
```

#### Option 2: Multiple agents in a square formation
```bash
bash tools/crazyflie-simulation/simulator_files/gazebo/launch/sitl_multiagent_square.sh -n 8 -m crazyflie
```

#### Option 3: Multiple agents from a coordinates file
```bash
bash tools/crazyflie-simulation/simulator_files/gazebo/launch/sitl_multiagent_text.sh -m crazyflie -f single_origin.txt
```

---

## Simulation Backend: MuJoCo

[MuJoCo](https://mujoco.org/) does not require Gazebo and tends to run with better real-time performance. Drone models and parameters are provided by the [drone-models](https://github.com/utiasDSL/drone-models) submodule.

The MuJoCo backend includes aerodynamic effects from the drone-models `first_principles` model:
- **Rotor drag**: velocity-dependent drag force using the `drag_matrix` from `params.toml`
- **Gyroscopic precession**: torque from body angular velocity and net rotor angular momentum


### MuJoCo Models

| Model | Description |
| --- | --- |
| cf2x_T350 | Crazyflie 2.x with Thrust upgrade kit (default) |
| cf2x_L250 | Crazyflie 2.x Standard Configuration |
| cf2x_P250 | Crazyflie 2.x Performance variant |
| cf21B_500 | Crazyflie 2.1B Brushless |

### Launch Scripts
Several launch scripts are included to simplify startup.

#### Option 1: Single agent
```bash
bash tools/crazyflie-simulation/simulator_files/mujoco/launch/sitl_singleagent.sh -m cf2x_T350 -x 0 -y 0
```

#### Option 2: Multiple agents in a square formation
```bash
bash tools/crazyflie-simulation/simulator_files/mujoco/launch/sitl_multiagent_square.sh -n 8 -m cf2x_T350
```

#### Option 3: Multiple agents from a coordinates file
```bash
bash tools/crazyflie-simulation/simulator_files/mujoco/launch/sitl_multiagent_text.sh -m cf2x_T350 -f single_origin.txt
```

---

### Coordinates File Format

The `-f` flag specifies a coordinates file from `crazyflie-firmware/tools/crazyflie-simulation/drone_spawn_list/`. Each line contains an X,Y spawn position in CSV format:

```
0.0,0.0
1.0,0.0
0.0,1.0
1.0,1.0
```

A default `single_origin.txt` file is included. To create your own, add a new `.txt` file to the `drone_spawn_list/` directory.

### Script Demo: 8-Drone Circling Demo (MuJoCo)

Create `circling_square.txt` spawn file.

Launch 8 drones using the `circling_square.txt` spawn file:
```bash
bash tools/crazyflie-simulation/simulator_files/mujoco/launch/sitl_multiagent_text.sh -m cf2x_T350 -f circling_square.txt -M 0.0379
```

Then in another terminal, run the circling square demo script:
```bash
cd crazyflie-lib-python/examples/autonomy
python3 circling_square_demo.py
```

Before running, update the `uris` list in the script to use SITL UDP URIs (`udp://127.0.0.1:19850` through `udp://127.0.0.1:19857` for 8 drones).


---

### Color LEDs (Top & Bottom)

The SITL firmware includes color LED deck drivers (`bcColorLedTop` and `bcColorLedBot`) that send RGB data to the simulator independently for the top and bottom LEDs. The MuJoCo backend renders these colors in real-time on the drone's `led_top` and `led_bot` materials and adds point light sources so the LEDs illuminate the surrounding scene. A headlight is also supported and rendered as a forward-facing spot light. LED RGB values set from cflib or cfclient are reflected in the simulation. A `scene_dark.xml` scene is provided to best visualize the LED lighting effects.

---

### 8-Drone Circling Demo (MuJoCo)

Launch 8 drones using the `circling_square.txt` spawn file:
```bash
bash tools/crazyflie-simulation/simulator_files/mujoco/launch/sitl_multiagent_text.sh -m cf2x_T350 -f circling_square.txt -M 0.0379
```

Then in another terminal, run the circling square demo script:
```bash
cd crazyflie-lib-python/examples/autonomy
python3 circling_square_demo.py
```

Before running, update the `uris` list in the script to use SITL UDP URIs (`udp://127.0.0.1:19850` through `udp://127.0.0.1:19857` for 8 drones).


https://github.com/user-attachments/assets/c5d08c86-e879-4121-aecf-5adb6c083b6c

---

### Multiranger

The MuJoCo backend supports the Multi-ranger deck, providing simulated ToF range sensors (front, back, left, right, up). An obstacle scene is included and can be loaded with the `-s` flag:
```bash
bash tools/crazyflie-simulation/simulator_files/mujoco/launch/sitl_singleagent.sh -m cf2x_T350 -x 0 -y 0 -s scene_obstacles.xml
```

This can be demonstrated using the `multiranger_pointcloud.py` example from [crazyflie-lib-python](https://github.com/bitcraze/crazyflie-lib-python/blob/master/examples/multiranger/multiranger_pointcloud.py), which renders a real-time 3D point cloud while allowing manual flight control via keyboard. To use it with SITL, change the URI to `udp://127.0.0.1:19850` as with the other examples.

https://github.com/user-attachments/assets/f1377d12-ce14-4be9-8d28-07209eee7b6c


---

### AI-Deck Camera (MuJoCo)

The MuJoCo backend supports simulated AI-deck camera streaming using the CPX protocol. A companion script `crazysim_cpx.py` emulates the ESP32 WiFi bridge, allowing unmodified cflib AI-deck scripts (e.g. `fpv.py`) to receive camera frames from the simulator exactly as they would from real hardware.

![CrazySim AI-Deck Camera SITL Architecture](docs/crazysim_cpx_architecture.png)

**How it works:**
- `crazysim.py` renders the drone's FPV camera using MuJoCo's offscreen renderer, converts to grayscale (matching the Himax HM01B0 sensor), and sends frames via UDP to `crazysim_cpx.py`
- `crazysim_cpx.py` wraps frames in CPX APP packets with the `0xBC` image header and bridges CRTP commands between cflib and the firmware — acting as the ESP32
- cflib clients connect via TCP and see the same CPX protocol as real hardware

**Launch:**

Terminal 1:
```bash
bash tools/crazyflie-simulation/simulator_files/mujoco/launch/sitl_camera.sh -s scene_obstacles.xml
```

Terminal 2:
```bash
python3 crazyflie-lib-python/examples/aideck/fpv.py tcp://127.0.0.1:5050
```
<img width="1457" height="600" alt="Screenshot from 2026-03-23 17-05-29" src="https://github.com/user-attachments/assets/b95e4f5a-3dc1-4c6c-9408-89bc4d6cdbd0" />

---

### Simulation Features

The MuJoCo backend includes optional physics and sensor features. All features are **off by default** and enabled via flags passed to the launch scripts. Run any script with `-h` to see all options.

#### Sensor Noise (`--sensor-noise`)

Realistic BMI088 IMU noise model with parameters from the [datasheet](https://www.bosch-sensortec.com/media/boschsensortec/downloads/datasheets/bst-bmi088-ds001.pdf) and validated against real Crazyflie 2.1 hardware:
- **White noise**: per-axis accelerometer (160/160/190 µg/√Hz X/Y/Z) and gyroscope (0.014 °/s/√Hz) noise density
- **Bias**: randomized per-drone at startup within datasheet offset tolerances (accel ±20 mg, gyro ±1 °/s)
- **Scale factor**: randomized gyro sensitivity within ±1% (datasheet tolerance)
- **Bias random walk**: measured via Allan variance from a real Crazyflie 2.1

Each drone is initialized with randomized bias and scale values, so no two simulated drones behave identically. The gyro bias is handled by the firmware's own calibration at startup, same as on real hardware.

```bash
# Single agent with sensor noise
bash tools/crazyflie-simulation/simulator_files/mujoco/launch/sitl_singleagent.sh --sensor-noise
```

#### Ground Effect (`--ground-effect`)

Models the increased thrust when a drone hovers near the ground. Uses the classical ground effect model where thrust increases as a function of height-to-rotor-radius ratio. This is noticeable when taking off or landing — the drone gets a slight boost close to the floor.

```bash
bash tools/crazyflie-simulation/simulator_files/mujoco/launch/sitl_singleagent.sh --ground-effect
```

#### Downwash (`--downwash`)

Simulates the aerodynamic interaction between drones when one flies above another. The upper drone's prop wash pushes the lower drone down and can cause instability. Uses a Gaussian decay model based on lateral offset and vertical separation. Only meaningful for multi-agent scenarios.

```bash
bash tools/crazyflie-simulation/simulator_files/mujoco/launch/sitl_multiagent_square.sh -n 4 --downwash
```

#### Wind and Turbulence (`--wind-speed`, `--turbulence`)

Constant wind field with optional stochastic gusts and Dryden turbulence:
- `--wind-speed <m/s>` — constant wind speed
- `--wind-direction <deg>` — wind direction in degrees (0=+X, 90=+Y, 180=-X, 270=-Y)
- `--gust-intensity <m/s>` — random gust peak deviation (Ornstein-Uhlenbeck process)
- `--turbulence <level>` — Dryden turbulence (`none`, `light`, `moderate`, `severe`)

```bash
# 2 m/s wind from +X with moderate turbulence
bash tools/crazyflie-simulation/simulator_files/mujoco/launch/sitl_singleagent.sh \
    --wind-speed 2 --wind-direction 0 --turbulence moderate
```

#### Flowdeck (`--flowdeck`)

Simulates the Bitcraze Flow deck v2 sensors:
- **VL53L1x TOF rangefinder** — downward-facing distance measurement using MuJoCo raycasting (`mj_ray`) at 40 Hz with the hardware-matching exponential noise model from `zranger2.c`
- **PMW3901 optical flow** — pixel displacement computed from body-frame velocity, height, and angular rate at 100 Hz, matching the UKF's `computeOutputFlow` model (Npix=30, thetapix=4.2 deg, omegaFactor=1.25)

When `--flowdeck` is enabled, external pose packets are suppressed so the estimator runs on TOF + flow only, the same as real hardware with a Flow deck. The pose code remains intact and is used when `--flowdeck` is not passed.

```bash
bash tools/crazyflie-simulation/simulator_files/mujoco/launch/sitl_singleagent.sh --flowdeck
```

#### Combining Features

All flags can be combined:
```bash
# Single agent with all features
bash tools/crazyflie-simulation/simulator_files/mujoco/launch/sitl_singleagent.sh \
    --sensor-noise --ground-effect --wind-speed 1.5 --turbulence light

# Multi-agent swarm with full physics
bash tools/crazyflie-simulation/simulator_files/mujoco/launch/sitl_multiagent_square.sh -n 8 \
    --sensor-noise --ground-effect --downwash --wind-speed 2 --turbulence moderate
```

---

### PID Tuning Example
One use case for simulating a crazyflie with the client is real time PID tuning. If you created a custom crazyflie with larger batteries, multiple decks, and upgraded motors, then it would be useful to tune the PIDs in a simulator platform before tuning live on hardware. An example of real time PID tuning is shown below.

MujoCo

https://github.com/user-attachments/assets/e7abb1c6-77c3-4ff5-81b7-611c88dacdda

#### Cflib Coding Tutorial

Inside the Docker container

```
cd ~/my_code
vi demo.py
```
Paste the following

```
#!/usr/bin/env python3
"""
cflib tutorial for CrazySim
===========================

Each demo is standalone and runs against a simulated Crazyflie over the
UDP link that CrazySim's cflib fork provides.

Usage:
    python3 crazysim_cflib_tutorial.py list
    python3 crazysim_cflib_tutorial.py 1
    python3 crazysim_cflib_tutorial.py 4 --uri udp://0.0.0.0:19851

Start with demo 1 and 2 (no motors). Demos 4 onward will actually fly
the drone in Gazebo, so make sure you have space in your world file.
"""

import argparse
import logging
import sys
import time

import cflib.crtp
from cflib.crazyflie import Crazyflie
from cflib.crazyflie.log import LogConfig
from cflib.crazyflie.syncCrazyflie import SyncCrazyflie
from cflib.crazyflie.syncLogger import SyncLogger
from cflib.positioning.motion_commander import MotionCommander
from cflib.positioning.position_hl_commander import PositionHlCommander

DEFAULT_URI = 'udp://0.0.0.0:19850'

# cflib is chatty at DEBUG; ERROR keeps the tutorial output readable.
logging.basicConfig(level=logging.ERROR)


# ---------------------------------------------------------------------------
# 1. Connecting
# ---------------------------------------------------------------------------

def demo_connect(uri):
    """Open a link, print what's on the other end, close cleanly.

    init_drivers() registers every CRTP backend, including the udpdriver
    that CrazySim's fork adds. Without it the udp:// scheme is unknown.
    """
    print('Scanning for interfaces...')
    for iface in cflib.crtp.scan_interfaces():
        print('  found:', iface[0])

    print(f'\nConnecting to {uri}')
    with SyncCrazyflie(uri, cf=Crazyflie(rw_cache='./cache')) as scf:
        print('Connected.')
        print('  firmware :', scf.cf.param.get_value('firmware.revision0'))
        print('  log vars :', len(scf.cf.log.toc.toc))
        print('  params   :', len(scf.cf.param.values))
    print('Disconnected.')


# ---------------------------------------------------------------------------
# 2. Parameters
# ---------------------------------------------------------------------------

def demo_params(uri):
    """Read and write parameters.

    Params are the drone's settings: estimator choice, controller gains,
    flight-mode flags. They're grouped as 'group.name'.
    """
    with SyncCrazyflie(uri, cf=Crazyflie(rw_cache='./cache')) as scf:
        cf = scf.cf

        for name in ('stabilizer.estimator',
                     'stabilizer.controller',
                     'commander.enHighLevel'):
            print(f'{name:28s} = {cf.param.get_value(name)}')

        # Writes are async; the drone acks and cflib updates its cache.
        print('\nEnabling high-level commander...')
        cf.param.set_value('commander.enHighLevel', '1')
        time.sleep(0.2)
        print('commander.enHighLevel        =',
              cf.param.get_value('commander.enHighLevel'))

        # Browse the TOC when you're hunting for a param name.
        names = sorted(f'{group}.{name}'
                       for group, entries in cf.param.toc.toc.items()
                       for name in entries)
        print(f'\n{len(names)} params available; first 15:')
        for full in names[:15]:
            print('  ', full)


# ---------------------------------------------------------------------------
# 3. Logging
# ---------------------------------------------------------------------------

def demo_logging_sync(uri):
    """Pull telemetry synchronously — simplest way to read state.

    A LogConfig is a block of variables the drone streams back at a fixed
    period. Max 26 bytes per block, so watch your variable count.
    """
    lg = LogConfig(name='Position', period_in_ms=100)
    lg.add_variable('stateEstimate.x', 'float')
    lg.add_variable('stateEstimate.y', 'float')
    lg.add_variable('stateEstimate.z', 'float')
    lg.add_variable('stabilizer.yaw', 'float')

    with SyncCrazyflie(uri, cf=Crazyflie(rw_cache='./cache')) as scf:
        print('Streaming pose for 5 seconds...')
        with SyncLogger(scf, lg) as logger:
            start = time.time()
            for timestamp, data, logconf in logger:
                print(f'  x={data["stateEstimate.x"]:+.2f} '
                      f'y={data["stateEstimate.y"]:+.2f} '
                      f'z={data["stateEstimate.z"]:+.2f} '
                      f'yaw={data["stabilizer.yaw"]:+.1f}')
                if time.time() - start > 5:
                    break


def demo_logging_async(uri):
    """Same data via callbacks — what you want inside a larger program.

    The callback fires on cflib's link thread, so keep it short and don't
    block in it.
    """
    def on_data(timestamp, data, logconf):
        print(f'  [{timestamp:>8}] vx={data["stateEstimate.vx"]:+.2f} '
              f'vy={data["stateEstimate.vy"]:+.2f} '
              f'vz={data["stateEstimate.vz"]:+.2f}')

    def on_error(logconf, msg):
        print('Log error:', msg)

    lg = LogConfig(name='Velocity', period_in_ms=200)
    lg.add_variable('stateEstimate.vx', 'float')
    lg.add_variable('stateEstimate.vy', 'float')
    lg.add_variable('stateEstimate.vz', 'float')

    with SyncCrazyflie(uri, cf=Crazyflie(rw_cache='./cache')) as scf:
        scf.cf.log.add_config(lg)
        lg.data_received_cb.add_callback(on_data)
        lg.error_cb.add_callback(on_error)

        lg.start()
        print('Logging asynchronously for 5 seconds...')
        time.sleep(5)
        lg.stop()


# ---------------------------------------------------------------------------
# 4. Flying: MotionCommander (relative moves)
# ---------------------------------------------------------------------------

def reset_estimator(scf):
    """Zero the Kalman filter and wait for it to settle.

    Do this before every flight. The estimator's position drifts to
    wherever it last thought it was, and takeoff from a bad estimate
    produces a very confused drone.
    """
    cf = scf.cf
    cf.param.set_value('kalman.resetEstimation', '1')
    time.sleep(0.1)
    cf.param.set_value('kalman.resetEstimation', '0')
    time.sleep(2.0)


def demo_motion_commander(uri):
    """Relative movement — think 'forward 0.5m', not 'go to (1,2)'.

    MotionCommander takes off on __enter__ and lands on __exit__, so the
    with-block guarantees the drone comes down even if something raises.
    """
    with SyncCrazyflie(uri, cf=Crazyflie(rw_cache='./cache')) as scf:
        reset_estimator(scf)

        with MotionCommander(scf, default_height=0.5) as mc:
            print('Took off to 0.5 m')
            time.sleep(2)

            print('Forward 0.5 m');    mc.forward(0.5); time.sleep(1)
            print('Left 0.5 m');       mc.left(0.5);    time.sleep(1)
            print('Back 0.5 m');       mc.back(0.5);    time.sleep(1)
            print('Right 0.5 m');      mc.right(0.5);   time.sleep(1)

            print('Turning 360 deg');  mc.turn_left(360)
            time.sleep(1)

            print('Up to 1.0 m');      mc.up(0.5);      time.sleep(2)
            print('Landing')
        # Landed and disarmed here.


# ---------------------------------------------------------------------------
# 5. Flying: PositionHlCommander (absolute waypoints)
# ---------------------------------------------------------------------------

def demo_position_commander(uri):
    """Absolute waypoints in the world frame — closer to how you'd fly
    a real trajectory. Requires commander.enHighLevel = 1.
    """
    with SyncCrazyflie(uri, cf=Crazyflie(rw_cache='./cache')) as scf:
        scf.cf.param.set_value('commander.enHighLevel', '1')
        reset_estimator(scf)

        with PositionHlCommander(
                scf,
                x=0.0, y=0.0, z=0.0,
                default_velocity=0.4,
                default_height=0.6) as pc:

            square = [(0.5, 0.0), (0.5, 0.5), (0.0, 0.5), (0.0, 0.0)]
            for x, y in square:
                print(f'Going to ({x}, {y}, 0.6)')
                pc.go_to(x, y, 0.6)
                time.sleep(0.5)

            print('Climbing to 1.0 m')
            pc.go_to(0.0, 0.0, 1.0)
            time.sleep(1)
            print('Landing')


# ---------------------------------------------------------------------------
# 6. Flying + logging together
# ---------------------------------------------------------------------------

def demo_fly_and_log(uri):
    """Run a flight while recording the trajectory, then dump a summary.

    This is the shape of most real experiments: command, record, analyze.
    """
    samples = []

    def on_data(timestamp, data, logconf):
        samples.append((timestamp,
                        data['stateEstimate.x'],
                        data['stateEstimate.y'],
                        data['stateEstimate.z']))

    lg = LogConfig(name='Traj', period_in_ms=50)
    for v in ('stateEstimate.x', 'stateEstimate.y', 'stateEstimate.z'):
        lg.add_variable(v, 'float')

    with SyncCrazyflie(uri, cf=Crazyflie(rw_cache='./cache')) as scf:
        scf.cf.log.add_config(lg)
        lg.data_received_cb.add_callback(on_data)
        lg.start()

        reset_estimator(scf)
        with MotionCommander(scf, default_height=0.5) as mc:
            time.sleep(2)
            mc.forward(0.8)
            time.sleep(1)
            mc.back(0.8)
            time.sleep(1)

        lg.stop()

    print(f'\nCaptured {len(samples)} samples')
    if samples:
        xs = [s[1] for s in samples]
        zs = [s[3] for s in samples]
        print(f'  x range: {min(xs):+.2f} to {max(xs):+.2f} m')
        print(f'  z range: {min(zs):+.2f} to {max(zs):+.2f} m')

        with open('trajectory.csv', 'w') as f:
            f.write('timestamp,x,y,z\n')
            for row in samples:
                f.write(','.join(str(c) for c in row) + '\n')
        print('  wrote trajectory.csv')


# ---------------------------------------------------------------------------

DEMOS = {
    1: ('connect',            demo_connect),
    2: ('params',             demo_params),
    3: ('logging (sync)',     demo_logging_sync),
    4: ('logging (async)',    demo_logging_async),
    5: ('motion commander',   demo_motion_commander),
    6: ('position commander', demo_position_commander),
    7: ('fly and log',        demo_fly_and_log),
}


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('demo', help='demo number, or "list"')
    ap.add_argument('--uri', default=DEFAULT_URI,
                    help=f'CRTP URI (default: {DEFAULT_URI})')
    args = ap.parse_args()

    if args.demo == 'list':
        for n, (name, _) in DEMOS.items():
            print(f'  {n}. {name}')
        return 0

    try:
        n = int(args.demo)
        name, fn = DEMOS[n]
    except (ValueError, KeyError):
        print(f'Unknown demo: {args.demo!r} (try "list")', file=sys.stderr)
        return 1

    cflib.crtp.init_drivers()
    print(f'=== Demo {n}: {name} ===\n')
    fn(args.uri)
    return 0


if __name__ == '__main__':
    sys.exit(main())
```

