% Add all directories to the path below path
function AddDirs(path)
% Add directory to path
addpath(path);

% Find all subdirectories
files = dir(path);
subDirs = files([files.isdir]);

% Add all sub directories to path
for i = 1:length(subDirs)
    % remove folders starting with .
    fname = subDirs(i).name;
    if fname(1) ~= '.'
        subPath = [path filesep subDirs(i).name];
        % Run recursive with all sub dirs
        AddDirs(subPath);
    end
end
end

