function [processMB, workspaceMB, diffMB] = meminfo(verbose)
%MEMINFO Return MATLAB process RSS and workspace variable memory in MB.
%   [PROCESSMB, WORKSPACEMB, DIFFMB] = MEMINFO() returns values without printing.
%   MEMINFO(true) prints a one-line summary to the command window.
%
%   PROCESSMB  - process resident set size (MB)
%   WORKSPACEMB - total bytes of variables in calling workspace (MB)
%   DIFFMB     - PROCESSMB - WORKSPACEMB (MB)
%
%   Works on Linux (reads /proc/self/status). On other platforms attempts to
%   use 'memory' (Windows) or 'ps' as a fallback.

if nargin < 1
    verbose = false;
end

% Workspace usage from caller workspace
w = evalin('caller', 'whos');
workspaceBytes = sum([w.bytes]);
workspaceMB = workspaceBytes / (1024^2);

% Get process RSS (kB -> MB)
processMB = NaN;
if ispc
    try
        m = memory;
        processMB = m.MemUsedMATLAB / (1024^2);
    catch
        % leave NaN
    end
else
    % Try /proc/self/status (Linux)
    fid = fopen('/proc/self/status','r');
    if fid ~= -1
        procKB = NaN;
        while ~feof(fid)
            line = fgetl(fid);
            if ischar(line) && startsWith(line, 'VmRSS:')
                parts = regexp(line, '\s+','split');
                if numel(parts) >= 2
                    procKB = str2double(parts{2});
                end
                break
            end
        end
        fclose(fid);
        if ~isnan(procKB)
            processMB = procKB / 1024;
        end
    end

    % Fallback to 'ps' if /proc not available or parsing failed
    if isnan(processMB)
        try
            % ps -o rss= gives RSS in KB for current PID
            pid = feature('getpid'); %#ok<FEATFPTR>
            cmd = sprintf('ps -o rss= -p %d', pid);
            [s, out] = system(cmd);
            if s == 0
                rssKB = str2double(strtrim(out));
                if ~isnan(rssKB)
                    processMB = rssKB / 1024;
                end
            end
        catch
            % keep NaN
        end
    end
end

diffMB = processMB - workspaceMB;

if verbose
    if isnan(processMB)
        fprintf('Process RSS: N/A | Workspace: %.2f MB\n', workspaceMB);
    else
        fprintf('Process RSS: %.2f MB | Workspace: %.2f MB | Diff: %.2f MB\n', ...
            processMB, workspaceMB, diffMB);
    end
end
end
