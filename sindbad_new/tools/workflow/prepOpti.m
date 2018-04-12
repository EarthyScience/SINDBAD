function [info, obs] = prepOpti(info)
%% prepares the info.opti 
% INPUT:    info
% OUTPUT:   info, obs



% steps:
%   1) get constraints
%   2) check constraints
%   3) funHandle for cost function

%% 1) create function handles and get constraints
fun_fields = fieldnames(info.opti.constraints.funName);
for jj=1:numel(fun_fields)
   info.opti.constraints.funHandle.(fun_fields{jj}) = str2func(info.opti.constraints.funName.(fun_fields{jj})); 
end

obs = info.opti.constraints.funHandle.import(info);

% also needs to get/create the uncertainties of the observations a) from a function, or b) defined in the
% config file and created here
% obs.unc.(VariableName)



%% 2) check constraints (not implemented yet)
% see checkData4TEM.m as reference -> this is very specific

%% 3) create function handle for the cost function












end