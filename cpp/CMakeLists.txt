cmake_minimum_required(VERSION 4.2)
project(Matlab_Eigen_benchmark)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_SCAN_FOR_MODULES OFF)

set(BASE_URL "https://suitesparse-collection-website.herokuapp.com/MM")
set(DOWNLOAD_DIR "${CMAKE_CURRENT_SOURCE_DIR}/matrices")

set(MATRICES
        "Janna/StocF-1465"
        "Janna/Flan_1565"
        "Rothberg/cfd2"
        "Rothberg/cfd1"
        "AMD/G3_circuit"
        "Wissgott/parabolic_fem"
        "GHS_psdef/apache2"
        "MaxPlanck/shallow_water1"
        "FIDAP/ex15"
)

if(NOT EXISTS "${DOWNLOAD_DIR}")
    file(MAKE_DIRECTORY "${DOWNLOAD_DIR}")
endif()

foreach(MAT_PATH ${MATRICES})
    get_filename_component(MAT_NAME "${MAT_PATH}" NAME)

    set(URL "${BASE_URL}/${MAT_PATH}.tar.gz")
    set(ARCHIVE_PATH "${DOWNLOAD_DIR}/${MAT_NAME}.tar.gz")
    set(FINAL_MTX "${DOWNLOAD_DIR}/${MAT_NAME}.mtx")

    if(EXISTS "${FINAL_MTX}")
        message(STATUS "Matrix file already exists: ${MAT_NAME}.mtx")
    else()
        message(STATUS "Downloading: ${URL}")
        file(DOWNLOAD "${URL}" "${ARCHIVE_PATH}" SHOW_PROGRESS STATUS DOWNLOAD_STATUS)

        list(GET DOWNLOAD_STATUS 0 STATUS_CODE)
        if(STATUS_CODE EQUAL 0)
            message(STATUS "Extracting ${MAT_NAME}...")

            set(TEMP_EXTRACT_DIR "${DOWNLOAD_DIR}/temp_${MAT_NAME}")
            file(ARCHIVE_EXTRACT
                    INPUT "${ARCHIVE_PATH}"
                    DESTINATION "${TEMP_EXTRACT_DIR}"
            )

            # Find all .mtx files
            file(GLOB_RECURSE FOUND_MTX_LIST "${TEMP_EXTRACT_DIR}/*.mtx")

            if(FOUND_MTX_LIST)
                # CRITICAL: Get only the first file from the list
                list(GET FOUND_MTX_LIST 0 SINGLE_MTX)

                # Move the primary mtx file to the base matrices folder
                file(RENAME "${SINGLE_MTX}" "${FINAL_MTX}")
                message(STATUS "Saved to: ${FINAL_MTX}")
            endif()

            # Cleanup
            file(REMOVE_RECURSE "${TEMP_EXTRACT_DIR}")
            file(REMOVE "${ARCHIVE_PATH}")
        else()
            message(WARNING "Failed to download ${MAT_NAME}. Status: ${DOWNLOAD_STATUS}")
        endif()
    endif()
endforeach()

include(FetchContent)
FetchContent_Declare(
        fast_matrix_market
        GIT_REPOSITORY https://github.com/alugowski/fast_matrix_market
        GIT_TAG main
        GIT_SHALLOW TRUE
)
FetchContent_MakeAvailable(fast_matrix_market)

find_package(Eigen3 REQUIRED)
find_package(BLAS)
find_package(OpenBLAS REQUIRED)
find_package(OpenMP REQUIRED)
find_package(SuiteSparse CONFIG REQUIRED)
add_executable(${PROJECT_NAME} "main.cpp" utils/utils.hpp)

# Enable High-Level optimization and vectorization
if (MSVC) # If we are using a Visual Studio C++ compiler
    # /O2: Optimize for speed
    # /arch: AVX2: Enable Intel Advanced Vector Extensions 2 to improve performance
    message("Using a MSVC")
    target_compile_options(${PROJECT_NAME} PRIVATE /arch:AVX2 /openmp)
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
        EIGEN_USE_LAPACKE
)
target_link_libraries(${PROJECT_NAME} PRIVATE ${SuiteSparse_LIBRARIES})
target_link_libraries(${PROJECT_NAME} PRIVATE
        Eigen3::Eigen
        SuiteSparse::cholmod
        fast_matrix_market::fast_matrix_market
        OpenBLAS::OpenBLAS
        OpenMP::OpenMP_CXX
)