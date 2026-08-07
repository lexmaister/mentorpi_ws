#!/bin/bash
# 
#  @file      run_ascamera_nodelet.sh
#  @brief     angstrong run run_ascamera_nodelet nodelet
#
#  Copyright (c) 2024 Angstrong Tech.Co.,Ltd
#
#  @author    Angstrong SDK develop Team
#  @date      2024/02/05
#  @version   1.0
#


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
        sudo "$CUR_DIR/run_ascamera_nodelet.sh" "$@"
        exit $?
    fi
fi

if [ -f /opt/ros/melodic/setup.bash ]; then
    source /opt/ros/melodic/setup.bash
elif [ -f /opt/ros/kinetic/setup.bash ]; then
    source /opt/ros/kinetic/setup.bash
elif [ -f /opt/ros/noetic/setup.bash ]; then
    source /opt/ros/noetic/setup.bash
else
    echo  "Error,Can't not found ros in /opt/"
fi

if [ "$(ps -aux | grep rosmaster | grep -v grep | wc -l)" -eq "0" ]; then
    roscore &
    sleep 3
fi

gcc_target=$(gcc -v 2>&1 | grep Target: | sed 's/Target: //g')
echo "Target: "${gcc_target}

cd $CUR_DIR/src/as_nodelet/libs/lib/${gcc_target}
libPath=$(pwd)
export LD_LIBRARY_PATH=$libPath:$LD_LIBRARY_PATH
echo "lib path:"${libPath}

cd $CUR_DIR
. devel/setup.bash

log_file=AngstrongsdkLog.txt
current_dir=$CUR_DIR"/src/as_nodelet/configurationfiles"

# rosrun as_nuwacam as_nuwacam_node
roslaunch ascamera_nodelet ascamera_nodelet.launch argPath:=$current_dir
