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
    profile clear % clear profiler
    profile on -memory
    % Build system
    n = size(A, 1);
    
    relerr(k) = solveSystem(A,n); %solve system
    profile off
    %sum workspace memory
    s = whos;
    workspace = sum([s.bytes])/1024^2;
    stats = profile('info');
    sizes(k) = n;
    mem_rss(k) = stats.FunctionTable(2).TotalMemAllocated/(1024^2)+workspace;
    times(k) = stats.FunctionTable(2).TotalTime;
    clear A x b xe S;

end

% Sort results by matrix size
[sz, idx] = sort(sizes);
times    = times(idx);
mem_rss  = mem_rss(idx);
relerr   = relerr(idx);

% Save results
results.sizes   = sz;
results.times   = times;
results.mem_rss = mem_rss;
results.relerr  = relerr;
save(strcat('solve_bench_results.mat'), 'results');

fprintf('Benchmark completed for %d matrices. Results saved to solve_bench_results.mat\n', nFiles);