#include <filesystem>
#include <string>
#include <vector>
#include <fstream>
#include <fast_matrix_market/app/Eigen.hpp>
#include <Eigen/CholmodSupport>
#include <chrono>
#include "utils/utils.hpp"



int main(const int argc, char* argv[]) {
    // Get the directory from command line
    if (argc < 2)
        throw std::logic_error("Usage: matlab_eigen_benchmark <directory with matrix files>");
    const std::filesystem::path directory = argv[1];

    Eigen::SparseMatrix<double> A;

    benchmark_results benchmark_results;
    for (const std::vector<std::string> files = get_matrix_files(directory); const std::string& matrix_file : files) {
        // Start the timer to measure total resolve time
        auto start = std::chrono::high_resolution_clock::now();

        std::ifstream stream(matrix_file);
        fast_matrix_market::read_matrix_market_eigen(stream, A);
        stream.close();

        // Get memory allocated after reading
        size_t mem_after_reading = get_current_setsize();

        // Create xe vector of ones and create vector b as b = A * xe
        Eigen::VectorXd xe = Eigen::VectorXd::Ones(A.rows());
        Eigen::VectorXd b = A * xe;

        // Initialize the Sparse Linear Matrix solver for applying Cholesky
        // Eigen::SimplicialLLT<Eigen::SparseMatrix<double>> solver;
        Eigen::CholmodSimplicialLLT<Eigen::SparseMatrix<double>> solver;

        // Compute the Cholesky factorization
        solver.compute(A);

        // Check if the Cholesky factorization has converged, thus if the matrix is definite positive
        if (solver.info() != Eigen::Success) {
            std::cerr << "Decomposition failed for: " << matrix_file << std::endl;
            continue;
        }

        // Solve the linear system Ax = b
        Eigen::VectorXd x = solver.solve(b);

        // Get memory allocated after solving the system
        size_t memory_after_solving = get_current_setsize();

        // Stop the timer
        auto end = std::chrono::high_resolution_clock::now();

        // Check if the solver has had success solving the system with the Cholesky decomposition of A
        if (solver.info() != Eigen::Success) {
            std::cerr << "Solving failed for: " << matrix_file << std::endl;
            continue;
        }

        // Calculate results for the current matrix
        benchmark_results.matrix_name = std::filesystem::path(matrix_file).stem().string(); // Get name of the matrix
        benchmark_results.rows = A.rows(); // Matrix rows
        benchmark_results.cols = A.cols(); // Matrix cols
        benchmark_results.relative_error = (x - xe).norm() / xe.norm(); // Relative error
        benchmark_results.time_elapsed = end - start; // Time to solve the system
        benchmark_results.memory_used = (memory_after_solving - mem_after_reading) / (1024 * 1024); // Memory used (RSS size)

        write_to_csv_file(benchmark_results);

        std::cout << "Matrix: " << benchmark_results.matrix_name
                << " | Dims:" << benchmark_results.rows << " x " << benchmark_results.cols
                << " | Relative Error: " << benchmark_results.relative_error
                << " | Time to solve: " << benchmark_results.time_elapsed
                << " | Memory used: " << benchmark_results.memory_used << "MB" << std::endl;
    }
    return 0;
}