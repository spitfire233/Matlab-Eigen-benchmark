#include <unsupported/Eigen/SparseExtra>
#include <Eigen/Sparse>
#include <filesystem>
#include <string>
#include <vector>
#include <matio.h>
using namespace std;
using namespace filesystem;
using namespace Eigen;




SparseMatrix<double> read_matrix_from_file(const path& matrix_file) {
    SparseMatrix<double> A;
    if (!matrix_file.has_extension())
        throw runtime_error("File  " + matrix_file.filename().string() + " has no extension!");

    if (matrix_file.extension().string() == ".mtx") {

    }
    return A;
}


int main(int argc, char* argv[]) {
    // Get the directory from command line
    const path directory = argv[1];

    // Check if the directory is valid
    if (directory.empty() || !is_directory(directory))
        throw logic_error("Must specify a valid directory! "
                          "Usage: matlab_eigen_benchmark <directory with matrix files>");

    // Dynamic array with files path for matrices files
    vector<path> files;

    // Recover all matrices files from the directory and all its subdirectories
    for (const directory_entry& entry: recursive_directory_iterator(directory,
                                                                    directory_options::skip_permission_denied)) {
        if (entry.is_regular_file())
            files.emplace_back(entry.path());
    }

    for (const path& matrix_file : files) {
        SparseMatrix<double> A = read_matrix_from_file(matrix_file);
    }

    return 0;
}




