function [info, f]   = prepTEM(info)
%% prepares the experiment and model run
% INPUT:    info
% OUTPUT:   info
%           f:      forcing structure 
%
% comment:  
%
% steps:
%   1) prepForcing
%   2) prepSpinup
%   3) prepParams
%   4) createArrays4Model
%   5) runPrec 

%% 1) prepare forcing data
% create function handles
fun_fields = fieldnames(info.tem.forcing.funName);
for jj=1:numel(fun_fields)
    info.tem.forcing.funHandle.(fun_fields{jj}) = str2func(info.tem.forcing.funName.(fun_fields{jj}));
end

% evaluate function handle in forcing
f  = info.tem.forcing.funHandle.import(info);


%% note: this was in the setupTEM
% create the output path if it not yet exists
if ~exist(info.experiment.outputDirPath, 'dir'), mkdir(info.experiment.outputDirPath);end


end