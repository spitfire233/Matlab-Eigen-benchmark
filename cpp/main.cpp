#include <filesystem>
#include <string>
#include <vector>
#include "utils/utils.hpp"



int main(const int argc, char* argv[]) {
    Eigen::SparseMatrix<double> A;
    for (const std::vector<std::string> files = get_matrix_files(MATRICES_FOLDER); const std::string& matrix_file : files) {

        auto [matrix_name,
              rows,
              cols,
              time_elapsed, relative_error] = calculate_matrix(matrix_file);

        std::cout << "Matrix: " << matrix_name
                << " | Dims:" << rows << " x " << cols
                << " | Relative Error: " << relative_error
                << " | Time to solve: " << time_elapsed << std::endl;
    }
    return 0;
}