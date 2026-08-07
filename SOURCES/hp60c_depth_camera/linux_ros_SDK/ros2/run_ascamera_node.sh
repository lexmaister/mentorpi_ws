#!/bin/bash
# 
#  @file      run_ascamera_node.sh
#  @brief     angstrong run run_ascamera_node node for ROS2
#
#  Copyright (c) 2023 Angstrong Tech.Co.,Ltd
#
#  @author    Angstrong SDK develop Team
#  @date      2023/03/29
#  @version   1.0
#

script_name="$0"

GREEN="\e[32;1m"
NORMAL="\e[39m"
RED="\e[31m"

CUR_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
# check for whitespace in $CUR_DIR and exit for safety reasons
grep -q "[[:space:]]" <<<"${CUR_DIR}" && { echo "\"${CUR_DIR}\" contains whitespace. Not supported. Aborting." >&2 ; exit 1 ; }

if [ -f /etc/udev/rules.d/angstrong-camera.rules ]; then
    echo -e "---run the script with normal permissions"
else
    if [ $EUID -ne 0 ]; then
        echo -e "${RED}---This script requires root privileges, trying to use sudo${NORMAL}"
        sudo "$CUR_DIR/$script_name" "$@"
        exit $?
    fi
fi

# ROS2
if [ -f /opt/ros/crystal/setup.bash ]; then
    source /opt/ros/crystal/setup.bash
elif [ -f /opt/ros/dashing/setup.bash ]; then
    source /opt/ros/dashing/setup.bash
elif [ -f /opt/ros/foxy/setup.bash ]; then
    source /opt/ros/foxy/setup.bash
elif [ -f /opt/ros/galactic/setup.bash ]; then
    source /opt/ros/galactic/setup.bash
elif [ -f /opt/ros/humble/setup.bash ]; then
    source /opt/ros/humble/setup.bash
elif [ -f /opt/ros/jazzy/setup.bash ]; then
    source /opt/ros/jazzy/setup.bash
else
    echo  "Error,Can't not found ros in /opt/"
fi

gcc_target=$(gcc -v 2>&1 | grep Target: | sed 's/Target: //g')
echo "Target: "${gcc_target}

cd $CUR_DIR/ascamera/libs/lib/${gcc_target}
libPath=$(pwd)
export LD_LIBRARY_PATH=$libPath:$LD_LIBRARY_PATH
echo "lib path:"${libPath}

cd $CUR_DIR/
. install/setup.bash

log_file=AngstrongsdkLog.txt
# ros2 run ascamera ascamera_node
# ros2 launch ascamera ascamera.launch.py 2>&1 | tee $log_file
ros2 launch ascamera ascamera.launch.py