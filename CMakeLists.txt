cmake_minimum_required(VERSION 3.22) # 4.2 is likely a typo; 3.22 is very stable
project(Matlab_Eigen_benchmark)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# --- 1. Dependencies via FetchContent ---
include(FetchContent)
FetchContent_Declare(
        fast_matrix_market
        GIT_REPOSITORY https://github.com/alugowski/fast_matrix_market
        GIT_TAG main
        GIT_SHALLOW TRUE
)
FetchContent_MakeAvailable(fast_matrix_market)

# --- 2. Dependencies via vcpkg (find_package is preferred) ---
find_package(Eigen3 REQUIRED)
find_package(MKL REQUIRED)

# --- 3. Executable Definition ---
add_executable(${PROJECT_NAME} main.cpp)

# --- 4. Optimization Flags (The "Speed" Block) ---
if(MSVC)
    # /O2: Speed, /Ot: Favor fast code, /Oi: Intrinsic functions
    # /arch:AVX2: Uses modern CPU instructions (Standard for benchmarks)
    target_compile_options(${PROJECT_NAME} PRIVATE /O2 /Ot /Oi /DNDEBUG /arch:AVX2)
else()
    target_compile_options(${PROJECT_NAME} PRIVATE -O3 -DNDEBUG -march=native)
endif()

# --- 5. Linking ---
target_link_libraries(${PROJECT_NAME} PRIVATE
        Eigen3::Eigen
        fast_matrix_market::fast_matrix_market
        MKL::MKL
)

# --- 6. Enable MKL for Eigen ---
target_compile_definitions(${PROJECT_NAME} PRIVATE EIGEN_USE_MKL_ALL)