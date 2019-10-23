% Find all subsequent called nodes of the elements given in nodes and add
% all links between these functions
% Node is expected to be a complete filenames of .m file
function [callGraph] = GetFunctionCalls(node, callGraph)

if (nargin <= 0)
    return 
end
if (nargin < 2)
    callGraph = struct();
    callGraph.Nodes = {node};
    callGraph.Links = {};
end

% Get child nodes on the top node only 
 childNodes = matlab.codetools.requiredFilesAndProducts(node, 'toponly');
%childNodes = matlab.codetools.requiredFilesAndProducts(node);

% Exclude the parent node, as these is alwalys listed
childNodes = childNodes(cellfun(@(x) ~isequal(x, node), childNodes));
if (length(childNodes) <= 0)
    return
end

% Collect all links from the parent to the childs
newLinks = vertcat(repmat({node}, 1, length(childNodes)), childNodes);
callGraph.Links = horzcat(callGraph.Links, newLinks);

% Collect all nodes that are not already listed
newNodes = childNodes(cellfun(@(x) ~any(cellfun(@(y) isequal(x, y), callGraph.Nodes)), childNodes));
callGraph.Nodes = [callGraph.Nodes, newNodes];

% Recursive call to run all childs
for i = 1 : length(newNodes)
    callGraph = GetFunctionCalls(newNodes{i}, callGraph);
end

end
