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

    % FIX 1: Sort by `n`, not by the original table column (which is still a string)
    [~, idx] = sort(S.(fields{1}));
    for i = 1:numel(fields)
        col = S.(fields{i});
        S.(fields{i}) = col(idx);
    end

    % FIX 2: Rename fields safely, checking existence before renaming
    oldFields = {'Order', 'Time elapsed', 'Relative error', 'Memory used'};
    newFields = {'sizes', 'times', 'relerr', 'mem_rss'};
    for i = 1:length(oldFields)
        old = matlab.lang.makeValidName(oldFields{i});
        if isfield(S, old)
            S.(newFields{i}) = S.(old);
            S = rmfield(S, old);
        end
    end
end