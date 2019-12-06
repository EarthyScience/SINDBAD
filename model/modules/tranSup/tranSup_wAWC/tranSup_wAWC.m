function [f,fe,fx,s,d,p] = tranSup_wAWC(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the supply limited transpiration as the minimum of fraction of total AWC
% and the actual available moisture
%
% Inputs:
%   - s.w.wSoil : total soil moisture
%   - s.wd.pawAct: actual extractable water
%   - s.wd.p_wSoilBase_wAWC: total maximum plant available water (FC-WP)
%
% Outputs:
%   - d.tranSup.tranSup: supply limited transpiration 
%
% Modifies:
%   - 
%
% References:
%   - Teuling, 2007 or 2009: Time scales....
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
d.tranSup.tranSup(:,tix)     =   sum(s.wd.pawAct,2) .* p.tranSup.tranFrac;
end
