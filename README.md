# Crazyflie Simulator Container For Crazyflie Digital Twin

Credits: Crazysim <https://github.com/gtfactslab/CrazySim>

**Authors:** Minhyuk Park 

## Introduction

This repository will teach you how to deploy the Crazysim simulator in a Docker container environment for testing cflib scripts in simulator. 

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


https://github.com/user-attachments/assets/c5d08c86-e879-4121-aecf-5adb6c083b6c
