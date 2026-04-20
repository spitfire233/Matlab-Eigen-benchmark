function S = csvToStruct(filename)
    % Read the CSV file as a table first
    T = readtable(filename, 'VariableNamingRule', 'preserve');

    % Delete the first column
    T(:,1) = [];

    % Convert table to struct
    S = struct();
    colNames = T.Properties.VariableNames;

    for i = 1:numel(colNames)
        % Sanitize field name (replace spaces/special chars with underscores)
        fieldName = matlab.lang.makeValidName(colNames{i});
        S.(fieldName) = T.(colNames{i});
    end

    fields = fieldnames(S);
    col1 = S.(fields{1});

    % Ensure col1 is a string array
    if iscell(col1)
        col1 = string(col1);
    end

    % Convert "NxN" -> N
    n = zeros(numel(col1), 1);
    for i = 1:numel(col1)
        parts = strsplit(col1(i), 'x');
        n(i) = str2double(parts{1});
    end

    % Overwrite first field with numeric values
    S.(fields{1}) = n;

    % FIX 1: Sort by `n`, not by the original table column (which is still a string)
    [~, idx] = sort(n);
    for i = 1:numel(fields)
        col = S.(fields{i});
        S.(fields{i}) = col(idx);
    end

    % FIX 2: Rename fields safely, checking existence before renaming
    oldFields = {'Dimensions', 'TimeElapsed', 'RelativeError', 'MemoryUsed'};
    newFields = {'sizes', 'times', 'relerr', 'mem_rss'};
    for i = 1:length(oldFields)
        old = matlab.lang.makeValidName(oldFields{i});
        if isfield(S, old)
            S.(newFields{i}) = S.(old);
            S = rmfield(S, old);
        end
    end
end