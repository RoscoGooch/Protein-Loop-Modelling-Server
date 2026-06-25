function out = unpackStruct(s)

    if iscell(s)
        % check if this should become struct array
        if all(cellfun(@isstruct, s))
            % convert back to struct array
            out = [s{:}];
        else
            out = cell(size(s));
            for i = 1:numel(s)
                out{i} = unpackStruct(s{i});
            end
        end

    elseif isstruct(s)
        fn = fieldnames(s);
        out = struct();
        for i = 1:numel(fn)
            f = fn{i};
            out.(f) = unpackStruct(s.(f));
        end

    else
        out = s;
    end
end