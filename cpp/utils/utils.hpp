#ifndef MATLAB_EIGEN_BENCHMARK_MEMORY_UTILS_H
#define MATLAB_EIGEN_BENCHMARK_MEMORY_UTILS_H
#include <iostream>
#ifdef _WIN32
#include <windows.h>
#include <psapi.h>
#define RESULTS_FILE "../results/Windows_benchmark"
#elif
#define RESULTS_FILE "../results/Linux_benchmark"
#endif

typedef struct _BENCHMARK_RESULTS {
    std::chrono::duration<double> time_elapsed;
    double relative_error;
    size_t memory_used;
} benchmark_results;

inline size_t get_current_setsize() {
#ifdef _WIN32 // If we are on Windows
    // Get the current process handle
    HANDLE hProcess = GetCurrentProcess();
    // Get the process memory statistics
    PROCESS_MEMORY_COUNTERS process_memory_counters;
    // Get the process memory infos and check if the macro does not fail
    if (hProcess != nullptr && GetProcessMemoryInfo(hProcess, &process_memory_counters, sizeof(process_memory_counters)))
        return process_memory_counters.WorkingSetSize; // Return the current Set Size of the process
    throw std::runtime_error("Error getting current process information!");
#else
    return 0;
#endif
}

inline std::vector<std::string> get_matrix_files(const std::filesystem::path& directory) {
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

inline void write_to_csv_file(const benchmark_results &benchmark_results) {
    std::fstream fstream;

    fstream.open(RESULTS_FILE, std::ios::out | std::ios::app);

    fstream << benchmark_results.time_elapsed << ","
            << benchmark_results.relative_error << ","
            << benchmark_results.memory_used;

    fstream.close();
}



#endif //MATLAB_EIGEN_BENCHMARK_MEMORY_UTILS_H
