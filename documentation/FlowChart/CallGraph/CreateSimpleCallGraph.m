% Create a struct from the call graph data to export later
function callGraphStruct = CreateSimpleCallGraph(callGraph)

callGraphStruct.Nodes = struct;
for i = 1:length(callGraph.Nodes)
    callGraphStruct.Nodes(i).Name = callGraph.Nodes{i}{1};
end

callGraphStruct.Links = struct;
for i = 1:size(callGraph.Links,2)
    callGraphStruct.Links(i).Source = callGraph.Links{1,i};
    callGraphStruct.Links(i).Target = callGraph.Links{2,i};
end
end
