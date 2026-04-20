clear, clc, close all;
% Prepare to measure multiple matrices: assume files named or a list provided.
% Here we scan the 'matrices' folder for .mat files matching pattern 'StocF-*.mat'
files = dir(fullfile('../matrices','*.mat'));
nFiles = numel(files);
if nFiles==0
    error('No matrix files found in matrices folder with pattern *.mat');
end

sizes = zeros(nFiles,1);
times = zeros(nFiles,1);
mem_rss = zeros(nFiles,1);
mem_ws = zeros(nFiles,1);
mem_diff = zeros(nFiles,1);
relerr = zeros(nFiles,1);

for k = 1:nFiles
    fname = fullfile(files(k).folder, files(k).name);
    S = load(fname);
    if isfield(S,'Problem') && isfield(S.Problem,'A')
        A = S.Problem.A;
    elseif isfield(S,'A')
        A = S.A;
    else
        error('File %s does not contain A or Problem.A', files(k).name);
    end
    % get size
    n = size(A,1);
    sizes(k) = n;
    xe = ones(n,1);
    b = A * xe;
    % memory/time before
    proc_before = meminfo();
    tStart = tic;
    x = A \ b;
    times(k) = toc(tStart);
    proc_after = meminfo();

    mem_rss(k) = proc_after-proc_before;
    relerr(k) = norm(x-xe)/norm(xe);
    % clean up before next iteration
    clear A x b xe S
    drawnow;
end

% Sort by matrix size for plotting
[sz, idx] = sort(sizes);
times = times(idx);
mem_rss = mem_rss(idx);
mem_ws = mem_ws(idx);
mem_diff = mem_diff(idx);
relerr = relerr(idx);

% Save results
results.sizes = sz;
results.times = times;
results.mem_rss = mem_rss;
results.relerr = relerr;
save('solve_bench_results.mat','results');

