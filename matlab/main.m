clear; clc; close all;

pid = feature('getpid');

folder = '../matrices';
files = dir(fullfile(folder, '*.mat'));

results = [];   % struct array

N = length(files);

% Preallocate
n_vals     = zeros(N,1);
time_vals  = zeros(N,1);
mem_vals   = zeros(N,1);
err_vals   = zeros(N,1);

for k = 1:length(files)

    file = fullfile(folder, files(k).name);
    fprintf('\nProcessing: %s\n', file);

     % Unique file per iteration (works on both OS)
    outfile = sprintf('mem_%d.txt', k);

    % Stop previous samplers (important on Windows)
    if ispc
        system('taskkill /F /IM powershell.exe >nul 2>&1');
    end

    % Delete old file safely
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
        '"Start-Process powershell -ArgumentList ''-ExecutionPolicy Bypass -File ../profilers/mem_sampler.ps1 %d %s'' -WindowStyle Hidden"' ...
        ], pid, outfile);

        system(cmd);
    else
        system(sprintf('../profilers/mem_sampler.sh %d %s &', pid, outfile));
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

    % ---- store ----
    n_vals(k)     = n;
    time_vals(k)  = solve_time;
    mem_vals(k)   = peak_MB;
    err_vals(k)   = relerr;
    
    clear A x b xe
    
end

if ispc
    system('taskkill /F /IM powershell.exe >nul 2>&1');
end

% Sort by matrix size
[~, idx] = sort(n_vals);

n     = n_vals(idx);
time  = time_vals(idx);
peak_MB   = mem_vals(idx);
relerr   = err_vals(idx);

% Save
save('results.mat', ...
    'n', ...
    'time', ...
    'peak_MB', ...
    'relerr');

fprintf('\nAll results saved to results.mat\n');