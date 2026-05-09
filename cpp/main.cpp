#include "utils/utils.hpp"

int main(const int argc, char* argv[]) {
    for (const std::vector<std::string> files = get_matrix_files(MATRICES_FOLDER); const std::string & matrix_file : files) {
        benchmark_results results = calulate_benchmark(matrix_file);
        std::cout << results << std::endl;
        write_to_csv_file(results);
    }
    return 0;
}