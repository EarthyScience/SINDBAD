function [info, obs] = prepOpti(info)
%% prepares the info.opti 
% INPUT:    info
% OUTPUT:   info, obs


% steps:
%   1) get constraints
%   2) check constraints
%   3) funHandle for cost function

%% 1) create function handles and get constraints (and their uncertainties)
fun_fields = fieldnames(info.opti.constraints.funName);
for jj=1:numel(fun_fields)
    try
        info.opti.constraints.funHandle.(fun_fields{jj}) = str2func(info.opti.constraints.funName.(fun_fields{jj}));
    end
end

obs = info.opti.constraints.funHandle.import(info);


%% 2) check constraints 
% so far based checkData4TEM.m 
if isfield(info.opti.constraints.funHandle, 'check') && ~isempty(info.opti.constraints.funHandle.check)
    [info,obs] = info.opti.constraints.funHandle.check(info,obs);    
end

%% 3) create function handle for the cost function and optimizer
info.opti.costFun.funHandle = str2func(info.opti.costFun.funName); 
info.opti.method.funHandle = str2func(info.opti.method.funName); 
% info.opti.costFun.(info.opti.costFun.costName).funHandle =
% str2func(info.opti.costFun.(info.opti.costFun.costName).funName); %sujan













end