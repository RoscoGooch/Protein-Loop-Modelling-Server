function out = packStruct(s)

    if isstruct(s)
        if numel(s) > 1
            % convert struct array to a cell array
            out = cell(size(s));
            for i = 1:numel(s)
                out{i} = packStruct(s(i));
            end
        else
            % if the struct is scalar, then recurse fields
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
        % base case, such as numerical, char and logical values
        out = s;.
    end
end