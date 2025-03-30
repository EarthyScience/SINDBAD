function [info] = editTEMInfo(info,varargin)
% @nc: seems that this function edits any part of the info, should actually
% be named editInfo? (Is replacing the old editTEMInfo
%% setups the experiment and TEM part of the info
% INPUT:    experiment configuration file OR an existing info
%           + additional command line informations what should be edited in the info
% OUTPUT:   info
% comment:  needs to be run where the repository is
%
% steps:
%   1) input = info or info.json file or experiment configuration file?
%     if configuration file:
%       - set info.experiment
%       - readConfigFiles
%   2) editINFOSettings
%   3) create the output folder structure
%   4) writeJsonFile of info
%   5) generate code and check model structure integrity
%   x) create helpers -> done in prepTEM as also forcing etc is needed
%   6) write the info structure in a mat file


%% 2) edit the settings of the TEM based on the function inputs
[info, tree]    =   editInfoField(info,varargin{:});
[info]          =   adjustInfo(info, tree);

%% 3) paths & output folder structure
% set the paths
[info]          =   setExperimentPath(info);

% create the output folder structure

end