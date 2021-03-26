function [f,fe,fx,s,d,p] = gwRec_dos(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates GW recharge as a fraction of soil moisture of the lowermost layer
%
% Inputs: 
%   - p.gwRec.rf
%   - s.w.wSoil
%
% Outputs:
%   - fx.gwRec 
%
% Modifies:
%   - s.w.wSoil
%   - s.w.wGW
% References:
%   - 
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 11.11.2019 (skoirala): clean up
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
% calculate recharge
wSoilEnd                =   size(s.w.wSoil,2);
dosSoilEnd              =  s.w.wSoil(:,wSoilEnd) ./ s.wd.p_wSoilBase_wSat(:,wSoilEnd);

fx.gwRec(:,tix)         =   ((dosSoilEnd) .^ (p.gwRec.dos_exp .* s.wd.p_wSoilBase_Beta(:,wSoilEnd))) .* s.w.wSoil(:,wSoilEnd);

% update storages pool
s.w.wSoil(:,wSoilEnd)   =   s.w.wSoil(:,wSoilEnd) - fx.gwRec(:,tix);
s.w.wGW                 =   s.w.wGW + fx.gwRec(:,tix);
end
