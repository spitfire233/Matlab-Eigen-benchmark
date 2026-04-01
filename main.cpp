#include <filesystem>
#include <string>
#include <vector>
#include <fstream>
#include <fast_matrix_market/app/Eigen.hpp>
#include <Eigen/Sparse>
#include <Eigen/src/SparseCholesky/SimplicialCholesky.h>


std::vector<std::string> get_matrix_files(const std::filesystem::path& directory) {
    // Check if the directory is valid
    if (directory.empty() || !is_directory(directory))
        throw std::logic_error("Must specify a valid directory!");
    std::vector<std::string> files;
    // Recover all matrices files from the directory and all its subdirectories
    for (const std::filesystem::directory_entry& entry: std::filesystem::directory_iterator(directory)) {
        if (entry.is_regular_file() && entry.path().has_extension() && entry.path().extension() == ".mtx")
            files.emplace_back(entry.path().string());
    }
    return files;
}

int main(const int argc, char* argv[]) {
    // Get the directory from command line
    if (argc < 2)
        throw std::logic_error("Usage: matlab_eigen_benchmark <directory with matrix files>");
    const std::filesystem::path directory = argv[1];

    Eigen::SparseMatrix<double> A;
    for (const std::vector<std::string> files = get_matrix_files(directory); const std::string& matrix_file : files) {
        std::ifstream stream(matrix_file);
        fast_matrix_market::read_matrix_market_eigen(stream, A);
        stream.close();

        // Create xe vector of ones and create vector b as b = A * xe
        Eigen::VectorXd xe = Eigen::VectorXd::Ones(A.rows());
        Eigen::VectorXd b = A * xe;

        // Initialize the Sparse Linear Matrix solver for applying Cholesky
        Eigen::SimplicialLLT<Eigen::SparseMatrix<double>> solver;

        // Compute the Cholesky factorization
        solver.compute(A);

        // Check if the Cholesky factorization has converged, thus if the matrix is definite positive
        if (solver.info() != Eigen::Success) {
            std::cerr << "Decomposition failed for: " << matrix_file << std::endl;
            continue;
        }

        // Solve the linear system Ax = b
        Eigen::VectorXd x = solver.solve(b);

        // Check if the solver has had success solving the system with the Cholesky decomposition of A
        if (solver.info() != Eigen::Success) {
            std::cerr << "Solving failed for: " << matrix_file << std::endl;
            continue;
        }
        // Output result or residual for verification
        double relative_error = (x - xe).norm() / xe.norm();
        std::cout << "Matrix: " << matrix_file << " | Relative Error: " << relative_error << std::endl;
    }
    return 0;
}