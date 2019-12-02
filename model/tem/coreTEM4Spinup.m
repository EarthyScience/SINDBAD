function [f,fe,fx,s,d,p] = coreTEM4Spinup(f,fe,fx,s,d,p,info)
% runs the coreTEM with ONLY the selected modules for reduced spinup of SINDBAD
%
% Requires:
%   - All SINDBAD structures: f,fe,fx,s,d,p,info
%   - A list of modules for which the use4spinup is true
%       - info.tem.model.code.ms.(module).use4spinup
%       - from modelStructure.json and setupCode.m
%
% Purposes:
%   - returns fSU,feSU,fxSU,precOnceDataSU,sSU,dSU,infoSU after running the coreTEM
%   - All SINDBAD structures with fluxes, states, and diagnostics from the selected modules for spinup
%
% Conventions:
%   - Only used when runGenCode is set to false in modelRun.json file
%   - When runGenCode is activated, the generated code for coreTEM is used.
%
% Created by:
%   - Sujan Koirala (skoirala)
%   - Nuno Carvalhais (ncarval)
%
% References:
%
% Versions:
%   - 1.0 on 10.07.2018

%%
%% get the list of modules that have use4spinup as true
ms                          =   info.tem.model.code.ms;
fullModList                 =   fields(ms);
for mod                     =   1:numel(fullModList)
    modSel                  =   fullModList{mod};
    if ~ms.(modSel).use4spinup
        ms                  =   rmfield(ms,modSel);
    end
end
spinupModList               =   fields(ms);

%% run the time loop for the selected modules for spinup
for tix                     =   1:info.tem.helpers.sizes.nTix
    for mod                 =   1:numel(spinupModList)
        modSel              =   spinupModList{mod};
        [f,fe,fx,s,d,p]     =   ms.(modSel).funHandle(f,fe,fx,s,d,p,info,tix);
    end
end

end
