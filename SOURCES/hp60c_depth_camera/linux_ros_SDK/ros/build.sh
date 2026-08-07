#!/bin/bash
# 
#  @file      build.sh
#  @brief     angstrong camera demo program build script for ros
#
#  Copyright (c) 2022 Angstrong Tech.Co.,Ltd
#
#  @author    Angstrong SDK develop Team
#  @date      2022/04/22
#  @version   1.0
#

if [ -f /opt/ros/melodic/setup.bash ]; then
    source /opt/ros/melodic/setup.bash
elif [ -f /opt/ros/kinetic/setup.bash ]; then
    source /opt/ros/kinetic/setup.bash
elif [ -f /opt/ros/noetic/setup.bash ]; then
    source /opt/ros/noetic/setup.bash
else
    echo  "Error,Can't not found ros in /opt/"
fi

# build ros as_vegacam_node node
# catkin_make -DCROSS_COMPILE=aarch64-linux-gnu-
# catkin_make -DCROSS_COMPILE=arm-linux-gnueabihf-
catkin_make
