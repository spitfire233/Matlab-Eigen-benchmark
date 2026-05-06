clear; clc; close all;

pid = feature('getpid');

folder = '../matrices';
files = dir(fullfile(folder, '*.mat'));

results = [];   % struct array

for k = 1:length(files)

    file = fullfile(folder, files(k).name);
    fprintf('\nProcessing: %s\n', file);

     % ✅ unique file per iteration (works on both OS)
    outfile = sprintf('mem_%d.txt', k);

    % ✅ stop previous samplers (important on Windows)
    if ispc
        system('taskkill /F /IM powershell.exe >nul 2>&1');
    end

    % ✅ delete old file safely
    if isfile(outfile)
        delete(outfile);
    end

    % load matrix
    S = load(file);
    A = S.Problem.A;
    clear S

    n = size(A,1);

    % start memory sampler
    if (ispc)
        system('taskkill /F /IM powershell.exe >nul 2>&1');
        outfile = sprintf('mem_%d.txt', k);
        cmd = sprintf([ ...
        'powershell -WindowStyle Hidden -Command ' ...
        '"Start-Process powershell -ArgumentList ''-ExecutionPolicy Bypass -File mem_sampler.ps1 %d %s'' -WindowStyle Hidden"' ...
        ], pid, outfile);

        system(cmd);
    else
        system(sprintf('./mem_sampler.sh %d %s &', pid, outfile));
    end
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
    mem_kb = data(:,1);
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