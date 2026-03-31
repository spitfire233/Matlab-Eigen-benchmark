cmake_minimum_required(VERSION 4.2)
project(Matlab_Eigen_benchmark)

set(CMAKE_CXX_STANDARD 26)

find_package(Eigen3 REQUIRED)
find_package(matio CONFIG REQUIRED)
add_executable(Matlab_Eigen_benchmark main.cpp)

target_link_libraries(Matlab_Eigen_benchmark PRIVATE
        Eigen3::Eigen
        matio::matio
)