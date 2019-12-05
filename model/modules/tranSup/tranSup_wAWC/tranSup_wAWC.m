function [f,fe,fx,s,d,p] = tranSup_wAWC(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the supply limited transpiration as the minimum of fraction of total AWC
% and the actual available moisture
%
% Inputs:
%   - s.w.wSoil : total soil moisture
%   - s.wd.p_rootFrac_fracRoot2SoilD: extractable fraction of water
%   - s.wd.p_wSoilBase_wAWC: total maximum plant available water (FC-WP)
%
% Outputs:
%   - d.tranSup.tranSup: supply limited transpiration 
%
% Modifies:
%   - 
%
% References:
%   - 
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
d.tranSup.tranSup(:,tix)     =   minsb(sum(s.wd.p_wSoilBase_wAWC .* s.wd.p_rootFrac_fracRoot2SoilD,2) .* p.tranSup.tranFrac,...
                                    sum(s.w.wSoil .* s.wd.p_rootFrac_fracRoot2SoilD,2));
end
