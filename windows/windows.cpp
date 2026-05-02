#include <filesystem>
#include <string>
#include <vector>
#include "utils/utils.hpp"

extern "C" void openblas_set_num_threads(int);
int main(const int argc, char* argv[]) {
    openblas_set_num_threads(std::thread::hardware_concurrency());
    Eigen::SparseMatrix<double> A;

    cholmod_common c;
    cholmod_start(&c);
    for (const std::vector<std::string> files = get_matrix_files(MATRICES_FOLDER); const std::string & matrix_file : files) {

        auto [matrix_name,
            rows,
            cols,
            time_elapsed, relative_error,
            memory_used] = calculate_matrix(matrix_file);

        std::cout << "Matrix: " << matrix_name
            << " | Dims:" << rows << " x " << cols
            << " | Relative Error: " << relative_error
            << " | Time to solve: " << time_elapsed 
            << " | Memory used by CHOLMOD: " << memory_used << "MB" << std::endl;
    }
    return 0;
}