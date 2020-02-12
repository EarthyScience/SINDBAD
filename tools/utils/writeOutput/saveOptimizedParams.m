function [outPath] = saveOptimizedParams(info, p)
% writes the optimized parameter values to a json file

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
