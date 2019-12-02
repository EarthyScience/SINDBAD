function [f,fe,fx,s,d,p] = runPrecOnceTEM(f,fe,fx,s,d,p,info)
% Runs the coreTEM with doPrecOnce = 1 for all the modules in the coreTEM that are not flagged
% as runAlways by setupCode
%
% Requires:
%    - all SINDBAD structure
%
% Purposes:
%   - Returns the fields of structures which can be calculated outside the
%   time loop
%
% Conventions:
%
% Created by:
%   - Nuno Carvalhais (ncarval)
%   - Sujan Koirala (skoirala)
%
% References:
%
% Versions:
%   - 1.0 on 01.05.2018

%% run the precOnce for all the modules that are not runAlways
for prc = 1:numel(info.tem.model.code.prec)
    if~info.tem.model.code.prec(prc).runAlways
        [f,fe,fx,s,d,p] = info.tem.model.code.prec(prc).funHandle(f,fe,fx,s,d,p,info);
    end
end
end
