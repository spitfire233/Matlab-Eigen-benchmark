cmake_minimum_required(VERSION 4.2)
project(Matlab_Eigen_benchmark)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_SCAN_FOR_MODULES OFF)

include(FetchContent)
FetchContent_Declare(
        fast_matrix_market
        GIT_REPOSITORY https://github.com/alugowski/fast_matrix_market
        GIT_TAG main
        GIT_SHALLOW TRUE
)
FetchContent_MakeAvailable(fast_matrix_market)

find_package(Eigen3 REQUIRED)
find_package(OpenBLAS REQUIRED)
find_package(CHOLMOD CONFIG REQUIRED)
find_package(SuiteSparse_config CONFIG REQUIRED)
add_executable(${PROJECT_NAME} main.cpp)

# Enable High-Level optimization and vectorization
if (MSVC) # If we are using a Visual Studio C++ compiler
    # /O2: Optimize for speed
    # /arch: AVX2: Enable Intel Advanced Vector Extensions 2 to improve performance
    message("Using a MSVC")
    target_compile_options(${PROJECT_NAME} PRIVATE /O2 /arch:AVX2)
else () # If we are on any other OS or not using a Microsoft Visual Studio C++ compiler
    # -O3: Aggressive optimization
    # -march=native Enables all instruction sets supported by the CPU
    # -DNDEBUG: Removes assertion macro to improve performance
    # -fopenmp: OpenBLAS is often compiled with multi-threading support
    message("Not using a MSVC")
    target_compile_options(${PROJECT_NAME} PRIVATE -O3 -march=native -DNDEBUG -fopenmp)
    target_link_options(${PROJECT_NAME} PRIVATE -fopenmp)
endif ()

# Disables Eigen's internal range checks and assertions
target_compile_definitions(${PROJECT_NAME} PRIVATE
        EIGEN_NO_DEBUG
        EIGEN_USE_BLAS
)

target_link_libraries(${PROJECT_NAME} PRIVATE
        Eigen3::Eigen
        SuiteSparse::CHOLMOD
        fast_matrix_market::fast_matrix_market
        OpenBLAS::OpenBLAS
)