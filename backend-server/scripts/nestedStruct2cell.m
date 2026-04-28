function C = nestedStruct2cell(S)
% nestedStruct2cell - Recursively convert a nested struct to a cell array
%
% Usage:
%   C = nestedStruct2cell(S)
%
% Input:
%   S - A MATLAB struct (can be nested)
%
% Output:
%   C - Cell array containing the struct's data

    % Validate input
    if ~isstruct(S)
        error('Input must be a struct.');
    end

    % If struct array, process each element
    if numel(S) > 1
        C = cell(size(S));
        for i = 1:numel(S)
            C{i} = nestedStruct2cell(S(i));
        end
        return;
    end

    % Get field names
    fields = fieldnames(S);
    C = cell(size(fields));

    % Loop through fields
    for i = 1:numel(fields)
        value = S.(fields{i});
        if isstruct(value)
            % Recursively convert nested struct
            C{i} = nestedStruct2cell(value);
        else
            % Store non-struct value directly
            C{i} = value;
        end
    end
end