cmake_minimum_required(VERSION 3.15)
project(patch)

set(CMAKE_CXX_STANDARD 14)
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -static-libstdc++ -static -static-libgcc")
add_executable(patch main.cpp)