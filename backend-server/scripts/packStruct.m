function out = packStruct(s)

    if isstruct(s)
        if numel(s) > 1
            % convert struct array → cell array
            out = cell(size(s));
            for i = 1:numel(s)
                out{i} = packStruct(s(i));
            end
        else
            % scalar struct → recurse fields
            fn = fieldnames(s);
            out = struct();
            for i = 1:numel(fn)
                f = fn{i};
                out.(f) = packStruct(s.(f));
            end
        end

    elseif iscell(s)
        out = cell(size(s));
        for i = 1:numel(s)
            out{i} = packStruct(s{i});
        end

    else
        out = s; % numeric, char, etc.
    end
end