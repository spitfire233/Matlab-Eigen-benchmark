#include <filesystem>
#include <string>
#include <vector>
#include <Eigen/Sparse>
using namespace std;
using namespace filesystem;

int main(int argc, char* argv[]) {
    // Get the directory from command line
    const path directory = argv[1];

    // Check if the directory is valid
    if (directory.empty() || !is_directory(directory))
        throw logic_error("Must specify a valid directory! "
                          "Usage: matlab_eigen_benchmark <directory with matrix files>");

    // Dynamic array with files path for matrices files
    vector<string> files;

    // Recover all matrices files from the directory and all its subdirectories
    for (const directory_entry& entry: directory_iterator(directory)) {
        if (entry.is_regular_file() && entry.path().has_extension() && entry.path().extension() == ".mtx")
            files.emplace_back(entry.path().string());
    }

    for (const string& matrix_file : files) {
        // Load a sparse matrix from .mtx
    }

    return 0;
}




