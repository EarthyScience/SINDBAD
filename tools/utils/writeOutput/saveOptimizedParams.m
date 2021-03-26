function [outPath] = saveOptimizedParams(info, p)
% writes the optimized parameter values to a json file
%
% Requires:
%   - info
%   - p: the parameter strucure with the optimized parameter values
%
% Purposes:
%   - save the optimized parameters into a json file that can be used for
%     a forward run
%
% Conventions:
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% References:
%
% Versions:
%   - 1.0 on 01.03.2020 (by skoirala) : 
%
%% create the structure that should be saved
out.type = 'value';

% loop only over optimized parameter
pa_opti  = info.opti.params.names;
for ii=1:numel(pa_opti)
    pa_parts    = strsplit(pa_opti{ii},'.');
    out.parameter.(pa_parts{2}).(pa_parts{3}) = p.(pa_parts{2}).(pa_parts{3});
end

%% outPutDir and name from info
outPath     = info.opti.paths.ParamFilePath;
%% save the json
jsonParam   = savejsonJL('',out,outPath);

end
