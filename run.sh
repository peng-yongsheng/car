docker run --rm --hostname devhost --name car --device=/dev/ttyUSB0 --device=/dev/dri:/dev/dri -e DISPLAY=$DISPLAY --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" -d car:latest
