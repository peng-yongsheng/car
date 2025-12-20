source $ROS_WS/devel/setup.bash
roslaunch car_slam car_cartographer.launch
roslaunch car_slam visualization.launch


socat -d -d TCP-LISTEN:2000,reuseaddr,fork FILE:/dev/cu.SLAB_USBtoUART,b115200,raw,echo=0


# Inside the Ubuntu container
apt-get update && apt-get install -y socat
socat -d -d PTY,link=/dev/ttyUSB0,raw,echo=0 TCP:host.docker.internal:2000
