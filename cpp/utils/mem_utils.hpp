#ifndef MATLAB_EIGEN_BENCHMARK_MEMORY_UTILS_H
#define MATLAB_EIGEN_BENCHMARK_MEMORY_UTILS_H

#ifdef _WIN32
#include <windows.h>
#include <Psapi.h>
size_t get_process_RSS() {
	PROCESS_MEMORY_COUNTERS_EX pmc;
	HANDLE process = GetCurrentProcess();
	if (GetProcessMemoryInfo(process, (PROCESS_MEMORY_COUNTERS*)&pmc, sizeof(pmc))) {
		return pmc.PrivateUsage; // Get roughly current memory allocated
	}
	throw std::runtime_error("Error loading the process!");
}
#endif


#endif
