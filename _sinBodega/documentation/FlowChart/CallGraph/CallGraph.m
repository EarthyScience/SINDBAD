% Root folder and root function to analyse
% rootFolder = 'D:\Git\matRad\';
% rootFunction = 'matRad.m';

rootFolder = '/Volumes/Kaam/Matlab_Works/sindbad/sandbox/testOpti/';
rootFunction = 'testSiteOpti.m';
outputPath = 'callGraphSB_testOpti.JSON';
% 
% rootFolder = '/Volumes/Kaam/Matlab_Works/sindbad/sandbox/TWS_Paper/';
% rootFunction = 'HowToRunTEM_TinasModel.m';
% 
% % Output path for the JSON
% outputPath = 'callGraphSB_TWS.JSON';

% Add all sub directories to the path
AddDirs(rootFolder);

% Build the call graph by recursively going through the subsequent
% function calls
functionCalls = GetFunctionCalls([rootFolder rootFunction]);

% Trim the file path names down and get the subdirectory structure beneath
% the root directory
functionCalls = TrimFunctionNodes(functionCalls, rootFolder);

% Build struct representing the callGraph
callGraphStruct = CreateSimpleCallGraph(functionCalls);

% Export a JSON containing the call graph
ExportStructAsJSON(callGraphStruct, outputPath);
