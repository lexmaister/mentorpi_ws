cmake_minimum_required(VERSION 2.8)
project(ascamera_demo)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_FLAGS -pthread)

add_compile_options(-std=c++11)

set(CMAKE_BUILD_TYPE "RELEASE")
set(CMAKE_CXX_FLAGS_RELEASE "$ENV{CXXFLAGS} -O3 -Wall")
# SET(CMAKE_BUILD_TYPE "Debug")
# SET(CMAKE_CXX_FLAGS_DEBUG "$ENV{CXXFLAGS} -O3 -Wall -g -fno-inline -ggdb")

# get gcc -v target
execute_process(COMMAND bash scripts/gettarget.sh WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} OUTPUT_VARIABLE gcc_target)
string(REGEX REPLACE "\n$" "" gcc_target "${gcc_target}")
message("default compiler:" ${gcc_target}-g++)

# ARM 
# SET(CROSS_COMPILE arm-linux-gnueabihf)
# SET(CROSS_COMPILE aarch64-linux-gnu)

# if (${gcc_target} MATCHES "x86_64" AND NOT DEFINED CROSS_COMPILE)
find_package(OpenCV QUIET)
if (OpenCV_FOUND)
message(STATUS "Found OpenCV version: ${OpenCV_VERSION}")
message(STATUS "Found OpenCV include folder: ${OpenCV_INCLUDE_DIRS}")
message(STATUS "Found OpenCV libs: ${OpenCV_LIBS}")
add_definitions(-DCFG_OPENCV_ON)

find_package(X11 QUIET)
if (X11_FOUND)
add_definitions(-DCFG_X11_ON)
set(X11_LIBS -lX11)
endif()

endif()
# endif()

if(CROSS_COMPILE)
if (${CROSS_COMPILE} MATCHES "aarch64")
SET(CMAKE_SYSTEM_PROCESSOR aarch64)
else()
SET(CMAKE_SYSTEM_PROCESSOR arm)
endif()
SET(CMAKE_C_COMPILER ${CROSS_COMPILE}-gcc)
SET(CMAKE_CXX_COMPILER ${CROSS_COMPILE}-g++)
SET(CMAKE_STRIP ${CROSS_COMPILE}-strip)
endif()

# Specify additional locations of header files
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/libs/include)
include_directories(${OpenCV_INCLUDE_DIRS})

if (CROSS_COMPILE)
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/libs/lib/${CROSS_COMPILE}/)
else()
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/libs/lib/${gcc_target}/)
endif()

# add to be built executable files
add_executable(ascamera ./src/main.cpp ./src/Demo.cpp ./src/CameraSrv.cpp ./src/Camera.cpp)
target_link_libraries(ascamera 
    -Wl,--start-group 
    AngstrongCameraSdk
    alg_kunlun
    AngKondyorArith
    Filt
    asuvc
    asusb
    turbojpeg
    zmq
    -Wl,--end-group
    ${OpenCV_LIBS}
    ${X11_LIBS}
)

