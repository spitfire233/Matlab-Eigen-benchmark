#pragma once // Ensure file is included only once

#include <filesystem>

#ifndef PROJECT_ROOT_DIR
#error PROJECT_ROOT_DIR not defined // Ensure project root macro is available
#endif

inline const std::filesystem::path ROOT_DIR = PROJECT_ROOT_DIR; // Project root directory
inline const std::filesystem::path PROFILER_PATH = PROFILERS_DIR; // Profilers directory
inline const std::filesystem::path MATRICES_PATH = MATRICES_DIR; // Matrices directory

#ifdef _WIN32
inline const std::filesystem::path PROFILER_SCRIPT_PATH = PROFILER_PATH / "mem_sampler.ps1"; // Windows profiler script
inline const std::filesystem::path RESULTS_FILE = ROOT_DIR / "results" / "windows_resulsts.csv"; // Windows results CSV
#else
inline const std::filesystem::path PROFILER_SCRIPT_PATH = PROFILER_PATH / "mem_sampler.sh"; // Linux/macOS profiler script
inline const std::filesystem::path RESULTS_FILE = ROOT_DIR / "results" / "linux_resulsts.csv"; // Linux results CSV

#endif