#ifndef MATLAB_EIGEN_BENCHMARK_MEMORY_UTILS_H // Include guard
#define MATLAB_EIGEN_BENCHMARK_MEMORY_UTILS_H

#include "paths.hpp"

#if defined(_WIN32)
#include <windows.h> // Windows API
#include <Psapi.h> // Process status API
#endif

// Return the current process PID
int get_pid() {
#ifdef _WIN32
    return static_cast<int>(GetCurrentProcessId()); // Windows PID retrieval
#else
    return static_cast<int>(getpid()); // Unix/Linux PID retrieval
#endif
}

// Start the external memory profiler
void start_sampler(int pid, const std::string& outfile) {

#if defined(_WIN32)
    // Kill previous profiler instances
    system("taskkill /F /IM powershell.exe >nul 2>&1");

    // Build PowerShell command to launch profiler
    std::string cmd =
        "powershell -WindowStyle Hidden -Command \""
        "Start-Process powershell "
        "-ArgumentList '-ExecutionPolicy Bypass -File "
        + PROFILER_SCRIPT_PATH.string() + " "
        + std::to_string(pid) + " " + outfile +
        "' -WindowStyle Hidden\"";

    // Execute profiler process
    system(cmd.c_str());

#else
    // Linux/macOS profiler launcher
    std::string cmd =
        "./mem_sampler.sh " +
        std::to_string(pid) +
        " " + outfile +
        " &";
    system(cmd.c_str());
#endif
}

// Read profiler output and return maximum memory usage
int read_mem_file_and_get_max(const std::string& filename) {
    int max = 0;

    // Open memory log file
    std::ifstream in(filename);

    // Temporary line buffer
    std::string line;

    // Skip CSV header
    std::getline(in, line);

    try {
        // Search for maximum value
        while (std::getline(in, line)) {
            if (std::stoi(line) > max) {
                max = stoi(line);
            }
        }
    }
    catch (const std::exception& e) {
        std::cout << "Invalid encoding: " << e.what() << std::endl;
    }

    return max;
}

#endif // MATLAB_EIGEN_BENCHMARK_MEMORY_UTILS_H