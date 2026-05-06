clear; clc; close all;

pid = feature('getpid');
outfile = 'mem.txt';

folder = '../matrices';
files = dir(fullfile(folder, '*.mat'));

results = [];   % struct array

for k = 1:length(files)

    file = fullfile(folder, files(k).name);
    fprintf('\nProcessing: %s\n', file);

    % clean old memory log
    if isfile(outfile)
        delete(outfile);
    end

    % load matrix
    S = load(file);
    A = S.Problem.A;
    clear S

    n = size(A,1);

    % start memory sampler
    system(sprintf('./mem_sampler.sh %d %s &', pid, outfile));
    pause(0.2);

    % computation
    tic
    xe = ones(n,1);
    b = A * xe;
    x = A \ b;
    relerr = norm(x - xe) / norm(xe);
    solve_time = toc;

    pause(0.2); % allow sampler to finish

    % read memory
    data = readmatrix(outfile);
    mem_kb = data(:,2);
    peak_MB = max(mem_kb) / 1024;

    fprintf('n = %d | time = %.3f s | mem = %.2f MB | err = %.2e\n', ...
        n, solve_time, peak_MB, relerr);

    % store result
    result.file = files(k).name;
    result.n = n;
    result.time = solve_time;
    result.peak_MB = peak_MB;
    result.relerr = relerr;

    results = [results; result]; %#ok<AGROW>

    clear A x b xe
end

% ✅ sort results by matrix size
[~, idx] = sort([results.n]);
results = results(idx);

% ✅ save everything
save('results.mat', 'results');

fprintf('\nAll results saved to results.mat\n');