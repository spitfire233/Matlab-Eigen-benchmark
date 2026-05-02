#ifndef MATLAB_EIGEN_BENCHMARK_MEMORY_UTILS_H
#define MATLAB_EIGEN_BENCHMARK_MEMORY_UTILS_H
#define MATRICES_FOLDER "../../../matrices"
#include <iostream>
#include <fstream>
#include <fast_matrix_market/app/Eigen.hpp>
#include <Eigen/CholmodSupport>
#include <chrono>
#ifdef _WIN32
#include <windows.h>
#include <psapi.h>
#define RESULTS_FILE "../results/Windows_benchmark.csv"
#elif
#define RESULTS_FILE "../results/Linux_benchmark.csv"
#endif

typedef struct BENCHMARK_RESULTS {
    std::string matrix_name;
    Eigen::Index rows{};
    Eigen::Index cols{};
    std::chrono::duration<double> time_elapsed{};
    double relative_error{};
    size_t memory_used;
} benchmark_results;

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

inline void write_to_csv_file(const benchmark_results& result) {
    const std::filesystem::path file_path = RESULTS_FILE;

    // Ensure directory exists
    std::filesystem::create_directories(file_path.parent_path());

    // Check if file already exists (to decide whether to write header)
    const bool file_exists = std::filesystem::exists(file_path);

    std::ofstream file(file_path, std::ios::app);

    if (!file.is_open()) {
        std::cerr << "Failed to open file: " << file_path << "\n";
        return;
    }

    // Write header only if file is new
    if (!file_exists) {
        file << "Name;Dimensions;Time elapsed;Relative error\n";
    }

    // Write data
    file << result.matrix_name << ";"
        << result.rows << "x" << result.cols << ";"
        << result.time_elapsed.count() << ";"
        << result.relative_error << ";";
}

inline benchmark_results calculate_matrix(const std::string& matrix_file) {
    benchmark_results benchmark_results;

    Eigen::SparseMatrix<double> A;

    // Start the timer to measure total resolve time
    auto start = std::chrono::high_resolution_clock::now();

    std::ifstream stream(matrix_file);
    fast_matrix_market::read_matrix_market_eigen(stream, A);
    stream.close();

    // Create xe vector of ones and create vector b as b = A * xe
    Eigen::VectorXd xe = Eigen::VectorXd::Ones(A.rows());
    Eigen::VectorXd b = A * xe;

    // Initialize the Sparse Linear Matrix solver for applying Cholesky
    //Eigen::SimplicialLLT<Eigen::SparseMatrix<double>> solver;
    //Eigen::CholmodDecomposition<Eigen::SparseMatrix<double>> solver;
    // TODO: Discuss what solver we should use!
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

    // Check if the solver has had success solving the system with the Cholesky decomposition of A
    if (solver.info() != Eigen::Success) {
        std::cerr << "Solving failed for: " << matrix_file << std::endl;
        throw std::runtime_error("The solver was not able to do the computation!");
    }

    // Calculate results for the current matrix
    benchmark_results.matrix_name = std::filesystem::path(matrix_file).stem().string(); // Get name of the matrix
    benchmark_results.rows = A.rows(); // Matrix rows
    benchmark_results.cols = A.cols(); // Matrix cols
    benchmark_results.relative_error = (x - xe).norm() / xe.norm(); // Relative error
    benchmark_results.time_elapsed = end - start; // Time to solve the system
    benchmark_results.memory_used = solver.cholmod().memory_usage / (1024 * 1024);
    return benchmark_results;
}

#endif //MATLAB_EIGEN_BENCHMARK_MEMORY_UTILS_H
