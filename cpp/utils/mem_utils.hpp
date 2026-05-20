#ifndef MATLAB_EIGEN_BENCHMARK_MEMORY_UTILS_H // Include guard
#define MATLAB_EIGEN_BENCHMARK_MEMORY_UTILS_H

#include "paths.hpp"

#if defined(_WIN32)
#include <windows.h> // Windows API
#include <Psapi.h> // Process status API
#else
#include <unistd.h>
#endif

// Return the current process PID
inline int get_pid() {
#ifdef _WIN32
    return static_cast<int>(GetCurrentProcessId()); // Windows PID retrieval
#else
    return static_cast<int>(getpid()); // Unix/Linux PID retrieval
#endif
}

inline double get_current_memory_usage() {
#if defined(_WIN32)
    PROCESS_MEMORY_COUNTERS pmc; // Get the counters that windows associates with the process

    // Open the process with the rights to read virtual memory and to query process information
    HANDLE process = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, get_pid());

    if (!process) // If failed to open the process
        return 0.0;

    // Get the process memory information
    GetProcessMemoryInfo(process, &pmc, sizeof(pmc));

    // Close the handle to the process
    CloseHandle(process);

    return (pmc.WorkingSetSize) / (1024.0 * 1024.0);

#else
    // Prepare system command
    std::string cmd = "ps -p " + std::to_string(get_pid()) + " -o rss=";

    // Launch the command and open the pipe to read its output
    FILE* pipe = popen(cmd.c_str(), "r");

    if (!pipe) // If failed to open the pipe
        return 0.0;

    // Prepare a buffer to read the pipe
    char buffer[128];

    std::string result;

    while (fgets(buffer, sizeof(buffer), pipe) != nullptr)
        result += buffer; // Read the output

    pclose(pipe); // Close the pipe

    return std::stod(result) / 1024.0;
#endif
}

// Start the external memory profiler
inline void start_sampler(int pid, const std::string& outfile) {

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

    // Pause the thread in order to wait for the profiler to start
    std::this_thread::sleep_for(std::chrono::milliseconds(500));

#else
    // Linux/macOS profiler launcher
    const std::string cmd =
        PROFILER_SCRIPT_PATH.string() + " " +
        std::to_string(pid) +
        " " + outfile +
        " &";
    system(cmd.c_str());
#endif
}

inline void stop_sampler() {
#if defined(_WIN32)
    std::this_thread::sleep_for(std::chrono::milliseconds(500));
    system("taskkill /F /IM powershell.exe >nul 2>&1");
#else
    system("pkill -f mem_sampler.sh >/dev/null 2>&1");
#endif
}



// Read profiler output and return maximum memory usage
inline double read_mem_file_and_get_max(const std::string& filename) {
    double max = 0.0;

    // Open memory log file
    std::ifstream in(filename);

    // Temporary line buffer
    std::string line;

    // Skip CSV header
    std::getline(in, line);

    try {
        // Search for maximum value
        while (std::getline(in, line)) {
            if (std::stod(line) > max) {
                max = stod(line);
            }
        }
    }
    catch (const std::exception& e) {
        std::cout << "Invalid encoding: " << e.what() << std::endl;
    }

    return max;
}

#endif // MATLAB_EIGEN_BENCHMARK_MEMORY_UTILS_H