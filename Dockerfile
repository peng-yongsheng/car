FROM ros:noetic
USER root

ENV http_proxy="http://172.17.0.1:10808"
ENV https_proxy="http://172.17.0.1:10808"
ARG DEBIAN_FRONTEND=noninteractive

ENV ROS_PYTHON_VERSION=3
ENV ROS_WS=/catkin_ws

# Upgrade Ubuntu and install helpful utilities
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y git wget curl net-tools iputils-ping
RUN apt-get install -y python3-pip python3-catkin-tools python3-vcstool python3-wstool python3-rosdep ninja-build stow

# Update apt repos so we can install ROS packages
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -

# Install ROS utilities
RUN apt update
RUN apt install -y ros-noetic-ros-base
RUN apt install -y ros-noetic-geometry-msgs
RUN apt install -y ros-noetic-roslint
RUN apt install -y ros-noetic-message-runtime
RUN apt install -y ros-noetic-nav-msgs
RUN apt install -y ros-noetic-pcl-conversions
RUN apt install -y ros-noetic-robot-state-publisher
RUN apt install -y ros-noetic-sensor-msgs
RUN apt install -y ros-noetic-std-msgs
RUN apt install -y ros-noetic-tf2 ros-noetic-tf2-eigen ros-noetic-tf2-ros
RUN apt install -y ros-noetic-urdf ros-noetic-visualization-msgs
RUN apt install -y ros-noetic-rviz

# I had problems when set to localhost, passing devhost IP via 'docker run' command fixes comms
ENV ROS_MASTER_URI=http://devhost:11311/
WORKDIR $ROS_WS

# OR this ---->
# To build from the official car repo on github, instead of your
# custom catkin_ws, just comment-out the COPY above and then uncomment the following two commands
COPY ./car_slam $ROS_WS/src/car/car_slam
COPY ./car_robot.repos $ROS_WS/src/car/
RUN vcs import < $ROS_WS/src/car/car_robot.repos

RUN wstool init src
RUN wstool merge -t src https://raw.githubusercontent.com/cartographer-project/cartographer_ros/master/cartographer_ros.rosinstall
RUN wstool update -t src

# Install diffbot ROS package dependencies
RUN rosdep update
RUN rosdep install --from-paths src --ignore-src --rosdistro=${ROS_DISTRO} -r -y

# Cartographer uses the abseil-cpp library that needs to be manually installed
RUN src/cartographer/scripts/install_abseil.sh

# Build all ROS packages from source code
RUN catkin config --extend /opt/ros/$ROS_DISTRO
RUN catkin build
#RUN #source install_isolated/setup.bash
#RUN #catkin_make_isolated --install --use-ninja

## Source our car environment
RUN sed --in-place --expression \
      '$isource "$ROS_WS/devel/setup.bash"' \
      /ros_entrypoint.sh

COPY ./car_entrypoint.sh /
COPY ./test.sh /

RUN apt-get install -y mesa-utils

# Set the entrypoint to the script
ENTRYPOINT ["/ros_entrypoint.sh"]