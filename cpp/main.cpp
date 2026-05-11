#include "utils/utils.hpp"
int main(const int argc, char* argv[]) {
    // Get the process PID
    const int pid = get_pid();

    // Define the memory file to use as a string
    const std::string mem_file = (PROFILER_PATH / "mem.txt").string();
    
    // Loop over every .mtx file in the matrix folder
    for (const std::vector<std::string> files = get_matrix_files(MATRICES_DIR); const std::string & matrix_file : files) {

        // Kill still running profiler, if any
        stop_sampler();

        // Remove previous memory file, if any
        if (std::filesystem::exists(mem_file)) {
            std::filesystem::remove(mem_file);
        }

        // Start the memory profiler in anothe process
        start_sampler(pid, mem_file);

        // Calculate the matrix benchmark resulsts
        benchmark_results results = calulate_benchmark(matrix_file, pid, mem_file);

        // Pause the thread in order to allow the profiler to finish writing
        std::this_thread::sleep_for(std::chrono::milliseconds(200));

        // Get the max memory used by the process (RSS) in MB
        results.memory_used = read_mem_file_and_get_max(mem_file) / (1024);

        // Print the results to terminal for debugging
        std::cout << results << std::endl;

        // Write the results to the CSV file
        write_to_csv_file(results);
    }

    // Kill last profiler process
    #ifdef _WIN32
        system("taskkill /F /IM powershell.exe >nul 2>&1");
    #endif

    return 0;
}