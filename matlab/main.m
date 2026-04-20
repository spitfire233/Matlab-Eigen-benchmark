clear; clc; close all;

% Scan the 'matrices' folder for .mat files
files = dir(fullfile('../matrices', '*.mat'));
nFiles = numel(files);

if nFiles == 0
    error('No matrix files found in matrices folder with pattern *.mat');
end

% Pre-allocate result arrays
sizes    = zeros(nFiles, 1);
times    = zeros(nFiles, 1);
mem_rss  = zeros(nFiles, 1);
mem_ws   = zeros(nFiles, 1);
mem_diff = zeros(nFiles, 1);
relerr   = zeros(nFiles, 1);

for k = 1:nFiles
    fname = fullfile(files(k).folder, files(k).name);
    S = load(fname);

    % Extract matrix A
    if isfield(S, 'Problem') && isfield(S.Problem, 'A')
        A = S.Problem.A;
    elseif isfield(S, 'A')
        A = S.A;
    else
        error('File %s does not contain A or Problem.A', files(k).name);
    end

    % Build system
    n        = size(A, 1);
    sizes(k) = n;
    xe       = ones(n, 1);
    b        = A * xe;

    % Measure memory and time
    proc_before = meminfo();
    tStart      = tic;
    x           = A \ b;
    times(k)    = toc(tStart);
    proc_after  = meminfo();

    mem_rss(k) = proc_after - proc_before;
    relerr(k)  = norm(x - xe) / norm(xe);

    % Clean up before next iteration
    clear A x b xe S;
    drawnow;
end

% Sort results by matrix size
[sz, idx] = sort(sizes);
times    = times(idx);
mem_rss  = mem_rss(idx);
mem_ws   = mem_ws(idx);
mem_diff = mem_diff(idx);
relerr   = relerr(idx);

% Save results
results.sizes   = sz;
results.times   = times;
results.mem_rss = mem_rss;
results.relerr  = relerr;
save('solve_bench_results.mat', 'results');

fprintf('Benchmark completed for %d matrices. Results saved to solve_bench_results.mat\n', nFiles);