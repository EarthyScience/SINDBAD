% Trim a file path down to the actual file name and additionally output the
% ordered subdirectories (from root to file)
% rootDir should be the name of upper most directory containing functions
function [trimedString, subDirs] = TrimPath(filePath, rootDir)

childPath = filePath(length(rootDir)+1:end);

% Split the string into substrings at the platform specific file seperator
pathSplit = strsplit(childPath, filesep);
subDirs = pathSplit(1:end-1);

% Get the actual filename
trimedString = pathSplit(end);

end
