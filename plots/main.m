clear; clc; close all;

%% =========================
% LOAD MATLAB results_linux_matlab
%% =========================
results_linux_matlab = load('linux_results.mat');

mat_dir_windows = 'matlab/windows';
cpp_dir_windows = 'cpp/windows';
cmp_dir_windows = 'comparison/windows';

if ~exist(mat_dir_windows, 'dir'), mkdir(mat_dir_windows); end
if ~exist(cpp_dir_windows, 'dir'), mkdir(cpp_dir_windows); end
if ~exist(cmp_dir_windows, 'dir'), mkdir(cmp_dir_windows); end

mat_dir_linux = 'matlab/linux';
cpp_dir_linux = 'cpp/linux';
cmp_dir_linux = 'comparison/linux';

if ~exist(mat_dir_linux, 'dir'), mkdir(mat_dir_linux); end
if ~exist(cpp_dir_linux, 'dir'), mkdir(cpp_dir_linux); end
if ~exist(cmp_dir_linux, 'dir'), mkdir(cmp_dir_linux); end

cmp_dir_complete = 'comparison/complete';
if ~exist(cmp_dir_complete, 'dir'), mkdir(cmp_dir_complete); end




%% =========================
% MATLAB PLOTS
%% =========================

% ---- Time ----
f1 = figure;
semilogy(results_linux_matlab.n, results_linux_matlab.time, '-o', 'LineWidth', 1.5);
xlabel('Matrix size (n)');
ylabel('Solve time (s)');
title('MATLAB: Time vs size');
grid on;
saveas(f1, fullfile(mat_dir_linux, 'time_vs_size.pdf'));

% ---- Memory ----
f2 = figure;
semilogy(results_linux_matlab.n, results_linux_matlab.peak_MB, '-o', 'LineWidth', 1.5);
xlabel('Matrix size (n)');
ylabel('Memory (MB)');
title('MATLAB: Memory vs size');
grid on;
saveas(f2, fullfile(mat_dir_linux, 'rss_vs_size.pdf'));

% ---- Error ----
f3 = figure;
semilogy(results_linux_matlab.n, results_linux_matlab.relerr, '-o', 'LineWidth', 1.5);
xlabel('Matrix size (n)');
ylabel('Relative error');
title('MATLAB: Relative error vs size');
grid on;
saveas(f3, fullfile(mat_dir_linux, 'relative_error_vs_size.pdf'));

%% =========================
% LOAD C++ results_linux_c
%% =========================
results_linux_c = CSVToStruct('linux_results.csv');

%% =========================
% C++ PLOTS
%% =========================

% ---- Time ----
f4 = figure;
semilogy(results_linux_c.sizes, results_linux_c.times, '-s', 'LineWidth', 1.5);
xlabel('Matrix size (n)');
ylabel('Solve time (s)');
title('C++: Time vs size');
grid on;
saveas(f4, fullfile(cpp_dir_linux, 'time_vs_size.pdf'));

% ---- Memory ----
f5 = figure;
semilogy(results_linux_c.sizes, results_linux_c.mem_rss, '-s', 'LineWidth', 1.5);
xlabel('Matrix size (n)');
ylabel('Memory (MB)');
title('C++: Memory vs size');
grid on;
saveas(f5, fullfile(cpp_dir_linux, 'rss_vs_size.pdf'));

% ---- Error ----
f6 = figure;
semilogy(results_linux_c.sizes, results_linux_c.relerr, '-s', 'LineWidth', 1.5);
xlabel('Matrix size (n)');
ylabel('Relative error');
title('C++: Relative error vs size');
grid on;
saveas(f6, fullfile(cpp_dir_linux, 'relative_error_vs_size.pdf'));

%% =========================
% COMPARISON PLOTS
%% =========================

% ---- TIME COMPARISON ----
f7 = figure;
semilogy(results_linux_matlab.n, results_linux_matlab.time, '-o', 'LineWidth', 1.5);
hold on
plot(results_linux_c.sizes, results_linux_c.times, '-s', 'LineWidth', 1.5);
hold off
xlabel('Matrix size (n)');
ylabel('Solve time (s)');
title('Time comparison: MATLAB vs C++');
legend('MATLAB', 'C++', "Location", "southeast");
grid on;
saveas(f7, fullfile(cmp_dir_linux, 'time_comparison.pdf'));

% ---- MEMORY COMPARISON ----
f8 = figure;
semilogy(results_linux_matlab.n, results_linux_matlab.peak_MB, '-o', 'LineWidth', 1.5);
hold on
semilogy(results_linux_c.sizes, results_linux_c.mem_rss, '-s', 'LineWidth', 1.5);
hold off
xlabel('Matrix size (n)');
ylabel('Memory (MB)');
title('Memory comparison: MATLAB vs C++');
legend('MATLAB', 'C++', "Location", "southeast");
grid on;
saveas(f8, fullfile(cmp_dir_linux, 'memory_comparison.pdf'));

% ---- ERROR COMPARISON ----
f9 = figure;
semilogy(results_linux_matlab.n, results_linux_matlab.relerr, '-o', 'LineWidth', 1.5);
hold on
semilogy(results_linux_c.sizes, results_linux_c.relerr, '-s', 'LineWidth', 1.5);
hold off
xlabel('Matrix size (n)');
ylabel('Relative error');
title('Relative error comparison: MATLAB vs C++');
legend('MATLAB', 'C++', "Location", "southeast");
grid on;
saveas(f9, fullfile(cmp_dir_linux, 'relative_error_comparison.pdf'));

%% =========================
% LOAD MATLAB results_windows_matlab
%% =========================
results_windows_matlab = load('windows_results.mat');

%% =========================
% MATLAB PLOTS
%% =========================

% ---- Time ----
f10 = figure;
semilogy(results_windows_matlab.n, results_windows_matlab.time, '-o', 'LineWidth', 1.5);
xlabel('Matrix size (n)');
ylabel('Solve time (s)');
title('MATLAB: Time vs size');
grid on;
saveas(f10, fullfile(mat_dir_windows, 'time_vs_size.pdf'));

% ---- Memory ----
f11 = figure;
semilogy(results_windows_matlab.n, results_windows_matlab.peak_MB, '-o', 'LineWidth', 1.5);
xlabel('Matrix size (n)');
ylabel('Memory (MB)');
title('MATLAB: Memory vs size');
grid on;
saveas(f11, fullfile(mat_dir_windows, 'rss_vs_size.pdf'));

% ---- Error ----
f12 = figure;
semilogy(results_windows_matlab.n, results_windows_matlab.relerr, '-o', 'LineWidth', 1.5);
xlabel('Matrix size (n)');
ylabel('Relative error');
title('MATLAB: Relative error vs size');
grid on;
saveas(f12, fullfile(mat_dir_windows, 'relative_error_vs_size.pdf'));

%% =========================
% LOAD C++ results_windows_c
%% =========================
results_windows_c = CSVToStruct('windows_results.csv');

%% =========================
% C++ PLOTS
%% =========================

% ---- Time ----
f13 = figure;
semilogy(results_windows_c.sizes, results_windows_c.times, '-s', 'LineWidth', 1.5);
xlabel('Matrix size (n)');
ylabel('Solve time (s)');
title('C++: Time vs size');
grid on;
saveas(13, fullfile(cpp_dir_windows, 'time_vs_size.pdf'));

% ---- Memory ----
f14 = figure;
semilogy(results_windows_c.sizes, results_windows_c.mem_rss, '-s', 'LineWidth', 1.5);
xlabel('Matrix size (n)');
ylabel('Memory (MB)');
title('C++: Memory vs size');
grid on;
saveas(f14, fullfile(cpp_dir_windows, 'rss_vs_size.pdf'));

% ---- Error ----
f15 = figure;
semilogy(results_windows_c.sizes, results_windows_c.relerr, '-s', 'LineWidth', 1.5);
xlabel('Matrix size (n)');
ylabel('Relative error');
title('C++: Relative error vs size');
grid on;
saveas(f15, fullfile(cpp_dir_windows, 'relative_error_vs_size.pdf'));

%% =========================
% COMPARISON PLOTS
%% =========================

% ---- TIME COMPARISON ----
f16 = figure;
semilogy(results_windows_matlab.n, results_windows_matlab.time, '-o', 'LineWidth', 1.5);
hold on
plot(results_windows_c.sizes, results_windows_c.times, '-s', 'LineWidth', 1.5);
hold off
xlabel('Matrix size (n)');
ylabel('Solve time (s)');
title('Time comparison: MATLAB vs C++');
legend('MATLAB', 'C++', "Location", "southeast");
grid on;
saveas(f16, fullfile(cmp_dir_windows, 'time_comparison.pdf'));

% ---- MEMORY COMPARISON ----
f17 = figure;
semilogy(results_windows_matlab.n, results_windows_matlab.peak_MB, '-o', 'LineWidth', 1.5);
hold on
semilogy(results_windows_c.sizes, results_windows_c.mem_rss, '-s', 'LineWidth', 1.5);
hold off
xlabel('Matrix size (n)');
ylabel('Memory (MB)');
title('Memory comparison: MATLAB vs C++');
legend('MATLAB', 'C++', "Location", "southeast");
grid on;
saveas(f17, fullfile(cmp_dir_windows, 'memory_comparison.pdf'));

% ---- ERROR COMPARISON ----
f18 = figure;
semilogy(results_windows_matlab.n, results_windows_matlab.relerr, '-o', 'LineWidth', 1.5);
hold on
semilogy(results_windows_c.sizes, results_windows_c.relerr, '-s', 'LineWidth', 1.5);
hold off
xlabel('Matrix size (n)');
ylabel('Relative error');
title('Relative error comparison: MATLAB vs C++');
legend('MATLAB', 'C++', "Location", "southeast");
grid on;
saveas(f18, fullfile(cmp_dir_windows, 'relative_error_comparison.pdf'));


%% =========================
%  TOTAL COMPARISON
%% =========================

f16 = figure;
semilogy(results_windows_matlab.n, results_windows_matlab.time, '-o', 'LineWidth', 1.5);
hold on
semilogy(results_windows_c.sizes, results_windows_c.times, '-s', 'LineWidth', 1.5);
hold on
semilogy(results_linux_matlab.n, results_linux_matlab.time, '-o', 'LineWidth', 1.5);
hold on
plot(results_linux_c.sizes, results_linux_c.times, '-s', 'LineWidth', 1.5);
hold off
xlabel('Matrix size (n)');
ylabel('Solve time (s)');
title('Time comparison: Complete');
legend('Windows:MATLAB', 'Windows:C++','Linux:MATLAB', 'Linux:C++', "Location", "southeast");
grid on;
saveas(f16, fullfile(cmp_dir_complete, 'time_comparison.pdf'));

% ---- MEMORY COMPARISON ----
f17 = figure;
semilogy(results_windows_matlab.n, results_windows_matlab.peak_MB, '-o', 'LineWidth', 1.5);
hold on
semilogy(results_windows_c.sizes, results_windows_c.mem_rss, '-s', 'LineWidth', 1.5);
hold on
semilogy(results_linux_matlab.n, results_linux_matlab.peak_MB, '-o', 'LineWidth', 1.5);
hold on
semilogy(results_linux_c.sizes, results_linux_c.mem_rss, '-s', 'LineWidth', 1.5);

hold off
xlabel('Matrix size (n)');
ylabel('Memory (MB)');
title('Memory comparison: Complete');
legend('Windows:MATLAB', 'Windows:C++','Linux:MATLAB', 'Linux:C++', "Location", "southeast");
grid on;
saveas(f17, fullfile(cmp_dir_complete, 'memory_comparison.pdf'));

% ---- ERROR COMPARISON ----
f18 = figure;
semilogy(results_windows_matlab.n, results_windows_matlab.relerr, '-o', 'LineWidth', 1.5);
hold on
semilogy(results_windows_c.sizes, results_windows_c.relerr, '-s', 'LineWidth', 1.5);
hold on
semilogy(results_linux_matlab.n, results_linux_matlab.relerr, '-o', 'LineWidth', 1.5);
hold on
semilogy(results_linux_c.sizes, results_linux_c.relerr, '-s', 'LineWidth', 1.5);
hold off
xlabel('Matrix size (n)');
ylabel('Relative error');
title('Relative error comparison: Complete');
legend('Windows:MATLAB', 'Windows:C++','Linux:MATLAB', 'Linux:C++', "Location", "southeast");
grid on;
saveas(f18, fullfile(cmp_dir_complete, 'relative_error_comparison.pdf'));

%% =========================
% DONE
%% =========================
fprintf('All plots generated successfully.\n');