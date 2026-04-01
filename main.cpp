#include <filesystem>
#include <string>
#include <vector>
#include <fstream>
#include <fast_matrix_market/app/Eigen.hpp>
#include <Eigen/Sparse>


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

int main(int argc, char* argv[]) {
    // Get the directory from command line
    if (argc < 2)
        throw std::logic_error("Usage: matlab_eigen_benchmark <directory with matrix files>");
    const std::filesystem::path directory = argv[1];

    Eigen::SparseMatrix<double> A;
    for (const std::vector<std::string> files = get_matrix_files(directory); const std::string& matrix_file : files) {
        std::ifstream stream(matrix_file);
        fast_matrix_market::read_matrix_market_eigen(stream, A);
        std::cout << A.cols() << " " << A.rows() << std::endl;
    }

    return 0;
}




