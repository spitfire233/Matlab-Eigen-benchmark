#ifndef MATLAB_EIGEN_BENCHMARK_UTILS_H
#define MATLAB_EIGEN_BENCHMARK_UTILS_H

#include <iostream>
#include <fstream>
#include <chrono>
#include <filesystem>
#include <string>
#include <vector>

#include <fast_matrix_market/app/Eigen.hpp>
#include <Eigen/CholmodSupport>

#include "mem_utils.hpp"

// Data structure to hold the benchmark results
typedef struct BENCHMARK_RESULTS {
    std::string matrix_name; // The name of the matrix
    Eigen::Index order{}; // The order of the square matrix
    std::chrono::duration<double> time_elapsed{}; // The total time elapsed to perform the calculation
    double relative_error = 0.0; // The relative error of the calculation 
    double memory_used = 0.0; // The memory used by the whole process for the calculation
} benchmark_results;

// Output operator override to print the benchmark_results structure
inline std::ostream& operator<<(std::ostream &os, const benchmark_results &result) {
        os << "Matrix: " << result.matrix_name
        << " | Order:" << result.order
        << " | Relative Error: " << result.relative_error
        << " | Time to solve: " << result.time_elapsed
        << " | Memory used by the process: " << result.memory_used << "MB" << std::endl;
    return os;
}

// Function to get all the .mtx files from a directory
inline std::vector<std::string> get_matrix_files(const std::filesystem::path& directory) {
    // Check if the directory is valid
    if (directory.empty() || !is_directory(directory))
        throw std::logic_error("Must specify a valid directory!");

    std::vector<std::string> files;

    // Recover all matrices files from the directory and all its subdirectories
    for (const std::filesystem::directory_entry& entry : std::filesystem::directory_iterator(directory)) {
        if (entry.is_regular_file() && entry.path().has_extension() && entry.path().extension() == ".mtx")
            files.emplace_back(entry.path().string());
    }

    return files;
}

// Function to write the benchmark results to a .csv file
inline void write_to_csv_file(const benchmark_results& result) {

    const std::filesystem::path file_path = RESULTS_FILE;

    // Ensure directory exists
    std::filesystem::create_directories(file_path.parent_path());

    // Check if file already exists (to decide whether to write header)
    const bool file_exists = std::filesystem::exists(file_path);

    // Create output file stream (ofstream)
    std::ofstream file(file_path, std::ios::app);

    // Check if the file was opened correctly
    if (!file.is_open()) {
        std::cerr << "Failed to open file: " << file_path << "\n";
        return;
    }

    // Write header only if file is new
    if (!file_exists) {
        file << "Name;Order;Time elapsed;Relative error;Memory used\n";
    }
    // Write data
    file << result.matrix_name << ";"
        << result.order << ";"
        << result.time_elapsed.count() << ";"
        << result.relative_error << ";"
        << result.memory_used << std::endl;
}

// Function to calculate the benchmark results for a matrix in .mtx format
inline benchmark_results calculate_benchmark(const std::string& matrix_file, const int pid, const std::string& mem_file) {
    
    // Prepare struct to hold results
    benchmark_results benchmark_results;

    // Create the matrix as a SparseMatrix
    Eigen::SparseMatrix<double> A;

    // Start the memory profiler
    start_sampler(pid, mem_file);

    // Create file input (reading) stream (ifstream)
    std::ifstream stream(matrix_file);

    // Reade the matrix contained in the .mtx file into A
    fast_matrix_market::read_matrix_market_eigen(stream, A);

    // Close the stream
    stream.close();

    // Start the timer to measure total resolve time
    auto start = std::chrono::high_resolution_clock::now();

    // Get current resident set size after reading the matrix
    const double mem_after_reading = get_current_memory_usage();

    // Create xe vector of ones
    Eigen::VectorXd xe = Eigen::VectorXd::Ones(A.rows());

    // Create vector b as b = A * xe
    Eigen::VectorXd b = A * xe;

    // Initialize the Sparse Linear Matrix solver for applying Cholesky; force SuperNodal to ensure multithreading
    Eigen::CholmodSupernodalLLT<Eigen::SparseMatrix<double>> solver;

    // Compute the Cholesky factorization
    solver.compute(A);

    // Check if the Cholesky factorization has converged, thus if the matrix is definite positive
    if (solver.info() != Eigen::Success) {
        std::cerr << "Decomposition failed for: " << matrix_file << std::endl;
        throw std::logic_error("Matrix is not definite positive!");
    }

    // Solve the linear system Ax = b
    Eigen::VectorXd x = solver.solve(b);

    // Stop the timer
    auto end = std::chrono::high_resolution_clock::now();

    // Stop the sampler
    stop_sampler();

    // Check if the solver has had success solving the system with the Cholesky decomposition of A
    if (solver.info() != Eigen::Success) {
        std::cerr << "Solving failed for: " << matrix_file << std::endl;
        throw std::runtime_error("The solver was not able to do the computation!");
    }

    // Calculate results for the current matrix and return
    benchmark_results.matrix_name = std::filesystem::path(matrix_file).stem().string(); // Get name of the matrix
    benchmark_results.order = A.rows(); // Matrix order as the number of rows
    benchmark_results.relative_error = (x - xe).norm() / xe.norm(); // Relative error
    benchmark_results.time_elapsed = end - start; // Time to solve the system
    benchmark_results.memory_used = read_mem_file_and_get_max(mem_file) - mem_after_reading;
    return benchmark_results;
}

#endif //MATLAB_EIGEN_BENCHMARK_UTILS_H
