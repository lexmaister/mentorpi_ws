#!/bin/bash
# 
#  @file      build.sh
#  @brief     angstrong camera demo program build script
#
#  Copyright (c) 2022 Angstrong Tech.Co.,Ltd
#
#  @author    Angstrong SDK develop Team
#  @date      2022/03/18
#  @version   1.0
#

CUR_DIR=$(dirname "$(readlink -f "$0")")
build_folder=$CUR_DIR/build

# compile demo program with specified compiler
function AS_Fun_Compile() {
    if [ $# -eq 0 ]; then
        echo "not specify compiler, use default g++ compiler"
        cmake ../
    else
        echo "compile demo program whit $1g++ compiler"
        cmake -DCROSS_COMPILE=$1 ../
    fi

    make clean
    make
}


## Main script
echo "Create compile directory..."

if [ ! -d $build_folder ]; then
    mkdir $build_folder
else
    echo "compile directory build exist..."
fi

echo "remove all file in build directory"
rm -rf $build_folder/*

echo "enter direcotry build"
cd $build_folder

echo "start to compile demo program..."

## if not specify compiler, will use the default g++,
# and if you want to use cross compile, specify the compiler, such as##
# AS_Fun_Compile aarch64-linux-gnu-
# AS_Fun_Compile arm-linux-gnueabihf-
AS_Fun_Compile $1

echo "finish"
