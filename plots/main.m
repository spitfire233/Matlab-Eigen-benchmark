clear; clc; close all;

%% =========================
% LOAD MATLAB RESULTS
%% =========================
results = load('../matlab/results.mat');

mat_dir = 'matlab/windows';
cpp_dir = 'cpp/windows';
cmp_dir = 'comparison/windows';

if ~exist(mat_dir, 'dir'), mkdir(mat_dir); end
if ~exist(cpp_dir, 'dir'), mkdir(cpp_dir); end
if ~exist(cmp_dir, 'dir'), mkdir(cmp_dir); end

%% =========================
% MATLAB PLOTS
%% =========================

% ---- Time ----
f1 = figure;
semilogy(results.n, results.time, '-o', 'LineWidth', 1.5);
xlabel('Matrix size (n)');
ylabel('Solve time (s)');
title('MATLAB: Time vs size');
grid on;
saveas(f1, fullfile(mat_dir, 'time_vs_size.png'));

% ---- Memory ----
f2 = figure;
semilogy(results.n, results.peak_MB, '-o', 'LineWidth', 1.5);
xlabel('Matrix size (n)');
ylabel('Memory RSS (MB)');
title('MATLAB: Memory vs size');
grid on;
saveas(f2, fullfile(mat_dir, 'rss_vs_size.png'));

% ---- Error ----
f3 = figure;
semilogy(results.n, results.relerr, '-o', 'LineWidth', 1.5);
xlabel('Matrix size (n)');
ylabel('Relative error');
title('MATLAB: Relative error vs size');
grid on;
saveas(f3, fullfile(mat_dir, 'relative_error_vs_size.png'));

%% =========================
% LOAD C++ RESULTS
%% =========================
S = CSVToStruct('../cpp/out/build/results/Windows_benchmark.csv');

%% =========================
% C++ PLOTS
%% =========================

% ---- Time ----
f4 = figure;
semilogy(S.sizes, S.times, '-s', 'LineWidth', 1.5);
xlabel('Matrix size (n)');
ylabel('Solve time (s)');
title('C++: Time vs size');
grid on;
saveas(f4, fullfile(cpp_dir, 'time_vs_size.png'));

% ---- Memory ----
f5 = figure;
semilogy(S.sizes, S.mem_rss, '-s', 'LineWidth', 1.5);
xlabel('Matrix size (n)');
ylabel('Memory RSS (MB)');
title('C++: Memory vs size');
grid on;
saveas(f5, fullfile(cpp_dir, 'rss_vs_size.png'));

% ---- Error ----
f6 = figure;
semilogy(S.sizes, S.relerr, '-s', 'LineWidth', 1.5);
xlabel('Matrix size (n)');
ylabel('Relative error');
title('C++: Relative error vs size');
grid on;
saveas(f6, fullfile(cpp_dir, 'relative_error_vs_size.png'));

%% =========================
% COMPARISON PLOTS
%% =========================

% ---- TIME COMPARISON ----
f7 = figure;
semilogy(results.n, results.time, '-o', 'LineWidth', 1.5);
hold on
plot(S.sizes, S.times, '-s', 'LineWidth', 1.5);
hold off
xlabel('Matrix size (n)');
ylabel('Solve time (s)');
title('Time comparison: MATLAB vs C++');
legend('MATLAB', 'C++');
grid on;
saveas(f7, fullfile(cmp_dir, 'time_comparison.png'));

% ---- MEMORY COMPARISON ----
f8 = figure;
semilogy(results.n, results.peak_MB, '-o', 'LineWidth', 1.5);
hold on
semilogy(S.sizes, S.mem_rss, '-s', 'LineWidth', 1.5);
hold off
xlabel('Matrix size (n)');
ylabel('Memory RSS (MB)');
title('Memory comparison: MATLAB vs C++');
legend('MATLAB', 'C++');
grid on;
saveas(f8, fullfile(cmp_dir, 'memory_comparison.png'));

% ---- ERROR COMPARISON ----
f9 = figure;
semilogy(results.n, results.relerr, '-o', 'LineWidth', 1.5);
hold on
semilogy(S.sizes, S.relerr, '-s', 'LineWidth', 1.5);
hold off
xlabel('Matrix size (n)');
ylabel('Relative error');
title('Relative error comparison: MATLAB vs C++');
legend('MATLAB', 'C++');
grid on;
saveas(f9, fullfile(cmp_dir, 'relative_error_comparison.png'));

%% =========================
% DONE
%% =========================
fprintf('All plots generated successfully.\n');