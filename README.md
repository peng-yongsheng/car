# car

# Install diffbot ROS package dependencies
RUN rosdep update
RUN rosdep install --from-paths src --ignore-src -r -y

# Build all ROS packages from source code
RUN catkin config --extend /opt/ros/$ROS_DISTRO
RUN catkin build

source /opt/ros/${ROS_DISTRO}/setup.bash

roslaunch car_slam car_cartographer.launch

source "$ROS_WS/devel/setup.bash"

RLException: ERROR: unable to contact ROS master at [http://devhost:11311/]

sed --in-place --expression '$isource "$ROS_WS/devel/setup.bash"' ros_entrypoint.sh
