function [info]    = checkINFOconsistency(info, varargin{:})
%% checks the (edited) info settings for dependent fields
% INPUT:    info
%           
% OUTPUT:   info

% steps:
%   1) do approach and params agree?
%   2) are param values in bounds?
%   3) are info.opti.params a subset of info.tem.params?
%   4) do flas.check.Numeric/Bounds and variables.to.check agree?

%% 1) approach & parameter

%% 2) bounds of parameter

%% 3) opti.params & tem.params
if isfield(info, 'opti')
    idxError = find(~ismember(info.opti.paramsList, info.tem.model.variables.paramInput));
    if idxError ~= 0
        for ii=1:length(idxError)
        warning(['Optimization paramter: ' info.opti.paramsList{idxError(ii)} ' not represented in the model structure and excluded from optimization!']);     
        tmp     = strsplit(info.opti.paramsList{idxError(ii)},'.');
        info.opti.params.(tmp{2})    = rmfield(info.opti.params.(tmp{2}), tmp{3})
        info.opti.paramsList(idxError(ii)) = [];
        info.opti.paramsScale(idxError(ii)) = [];
        end
    end
end


%% 4) checks numeric and bounds
info.tem.model.flags.checks.bounds
info.tem.model.flags.checks.bounds

end