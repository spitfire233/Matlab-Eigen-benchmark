cmake_minimum_required(VERSION 4.2) # Require at least CMake version 4.2
project(Matlab_Eigen_benchmark) # Define the project name

set(CMAKE_CXX_STANDARD 20) # Use the C++20 standard
set(CMAKE_CXX_STANDARD_REQUIRED ON) # Make C++20 mandatory
set(CMAKE_CXX_SCAN_FOR_MODULES OFF) # Disable automatic module scanning

include(GNUInstallDirs) # Include standard GNU install directory variables

set(PROJECT_ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}") # Root directory of the cpp project
set(PROFILERS_DIR "${PROJECT_ROOT_DIR}/../profilers") # Path to profilers directory
set(MATRICES_DIR "${PROJECT_ROOT_DIR}/matrices") # Path to matrices directory

set(BASE_URL "https://suitesparse-collection-website.herokuapp.com/MM") # Base URL for SuiteSparse matrix downloads

set(MATRICES # List of matrices to download and benchmark
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

if(NOT EXISTS "${MATRICES_DIR}") # Check if the matrices directory exists
    file(MAKE_DIRECTORY "${MATRICES_DIR}") # Create matrices directory if missing
endif()

foreach(MAT_PATH ${MATRICES}) # Iterate through all matrix paths
    get_filename_component(MAT_NAME "${MAT_PATH}" NAME) # Extract matrix file name from path

    set(URL "${BASE_URL}/${MAT_PATH}.tar.gz") # Build download URL
    set(ARCHIVE_PATH "${MATRICES_DIR}/${MAT_NAME}.tar.gz") # Path to temporary downloaded archive
    set(FINAL_MTX "${MATRICES_DIR}/${MAT_NAME}.mtx") # Final extracted matrix file path

    if(EXISTS "${FINAL_MTX}") # Skip download if matrix already exists
        message(STATUS "Matrix file already exists: ${MAT_NAME}.mtx")
    else()
        message(STATUS "Downloading: ${URL}") # Print download message
        file(DOWNLOAD "${URL}" "${ARCHIVE_PATH}" SHOW_PROGRESS STATUS DOWNLOAD_STATUS) # Download matrix archive

        list(GET DOWNLOAD_STATUS 0 STATUS_CODE) # Extract download status code
        if(STATUS_CODE EQUAL 0) # Check if download succeeded
            message(STATUS "Extracting ${MAT_NAME}...")

            set(TEMP_EXTRACT_DIR "${MATRICES_DIR}/temp_${MAT_NAME}") # Temporary extraction directory
            file(ARCHIVE_EXTRACT
                    INPUT "${ARCHIVE_PATH}" # Archive to extract
                    DESTINATION "${TEMP_EXTRACT_DIR}" # Extraction destination
            )

            # Find all .mtx files
            file(GLOB_RECURSE FOUND_MTX_LIST "${TEMP_EXTRACT_DIR}/*.mtx") # Search recursively for matrix files

            if(FOUND_MTX_LIST) # Ensure at least one matrix file was found
                # CRITICAL: Get only the first file from the list
                list(GET FOUND_MTX_LIST 0 SINGLE_MTX) # Select the first .mtx file

                # Move the primary mtx file to the base matrices folder
                file(RENAME "${SINGLE_MTX}" "${FINAL_MTX}") # Move extracted matrix to final destination
                message(STATUS "Saved to: ${FINAL_MTX}") # Print save confirmation
            endif()

            # Cleanup
            file(REMOVE_RECURSE "${TEMP_EXTRACT_DIR}") # Remove temporary extraction directory
            file(REMOVE "${ARCHIVE_PATH}") # Remove downloaded archive
        else()
            message(WARNING "Failed to download ${MAT_NAME}. Status: ${DOWNLOAD_STATUS}") # Warn if download failed
        endif()
    endif()
endforeach()

include(FetchContent) # Enable dependency fetching from external repositories
FetchContent_Declare(
        fast_matrix_market # Declare external dependency
        GIT_REPOSITORY https://github.com/alugowski/fast_matrix_market # Git repository URL
        GIT_TAG main # Use main branch
        GIT_SHALLOW TRUE # Perform shallow clone for faster download
)
FetchContent_MakeAvailable(fast_matrix_market) # Download and make dependency available

find_package(Eigen3 REQUIRED) # Locate Eigen3 library
find_package(BLAS) # Locate generic BLAS library
find_package(OpenBLAS REQUIRED) # Locate OpenBLAS library
find_package(OpenMP REQUIRED) # Locate OpenMP support
find_package(SuiteSparse CONFIG REQUIRED) # Locate SuiteSparse package
add_executable(${PROJECT_NAME} "main.cpp" utils/utils.hpp) # Create executable target

# Enable High-Level optimization and vectorization
if (MSVC) # If we are using a Visual Studio C++ compiler
    # /O2: Optimize for speed
    # /arch: AVX2: Enable Intel Advanced Vector Extensions 2 to improve performance
    message("Using a MSVC") # Print compiler information
    target_compile_options(${PROJECT_NAME} PRIVATE /arch:AVX2 /openmp) # Enable AVX2 and OpenMP for MSVC
else () # If we are on any other OS or not using a Microsoft Visual Studio C++ compiler
    # -O3: Aggressive optimization
    # -march=native Enables all instruction sets supported by the CPU
    # -DNDEBUG: Removes assertion macro to improve performance
    # -fopenmp: OpenBLAS is often compiled with multi-threading support
    message("Not using a MSVC") # Print compiler information
    target_compile_options(${PROJECT_NAME} PRIVATE -O3 -march=native -DNDEBUG -fopenmp) # Enable aggressive optimizations
    target_link_options(${PROJECT_NAME} PRIVATE -fopenmp) # Link against OpenMP runtime
endif ()

# Disables Eigen's internal range checks and assertions
target_compile_definitions(${PROJECT_NAME} PRIVATE
        PROJECT_ROOT_DIR=\"${PROJECT_ROOT_DIR}\" # Expose project root path as a macro
        PROFILERS_DIR=\"${PROFILERS_DIR}\" # Expose profilers directory path as a macro
        MATRICES_DIR=\"${MATRICES_DIR}\" # Expose matrices directory path as a macro
        EIGEN_NO_DEBUG # Disable Eigen debug checks
        EIGEN_USE_BLAS # Enable BLAS backend in Eigen
        EIGEN_USE_LAPACKE # Enable LAPACKE backend in Eigen
)
target_link_libraries(${PROJECT_NAME} PRIVATE ${SuiteSparse_LIBRARIES}) # Link SuiteSparse libraries
target_link_libraries(${PROJECT_NAME} PRIVATE
        Eigen3::Eigen # Link Eigen library
        SuiteSparse::cholmod # Link CHOLMOD sparse matrix library
        fast_matrix_market::fast_matrix_market # Link fast matrix market parser
        OpenBLAS::OpenBLAS # Link OpenBLAS implementation
        OpenMP::OpenMP_CXX # Link OpenMP C++ support
)