cmake_minimum_required(VERSION 4.2)
project(Matlab_Eigen_benchmark)

set(CMAKE_CXX_STANDARD 26)

find_package(Eigen3 REQUIRED)
add_executable(${PROJECT_NAME} main.cpp)

target_link_libraries(${PROJECT_NAME} PRIVATE
        Eigen3::Eigen
        ${ARMADILLO_LIBRARIES}
)

target_include_directories(${PROJECT_NAME} PRIVATE
        ${ARMADILLO_INCLUDE_DIRS}
)