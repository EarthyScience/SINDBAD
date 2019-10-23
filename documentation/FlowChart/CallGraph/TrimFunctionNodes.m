% Trim the path names of the nodes down to the actual filenames. 
% Directory structure down to the individual file in captured in the struct
% subDirs
function [callGraph] = TrimFunctionNodes(callGraph, rootFolder)

% Trim path names in nodes and get the according subdirectories
for i = 1:length(callGraph.Nodes)
    [callGraph.Nodes{i}, callGraph.SubDirs{i}] = TrimPath(callGraph.Nodes{i}, rootFolder);
end
    
% Trim path names in links
callGraph.Links = cellfun(@(x) TrimPath(x, rootFolder), callGraph.Links);

end
