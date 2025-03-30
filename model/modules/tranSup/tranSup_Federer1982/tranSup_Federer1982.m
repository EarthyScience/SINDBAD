function [f,fe,fx,s,d,p] = tranSup_Federer1982(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the supply limited transpiration as a function of max rate parameter
% and avaialable water
%
% Inputs:
%   - s.w.wSoil : total soil moisture
%   - s.wd.pawAct: actual extractable water
%   - s.wd.p_wSoilBase_wAWC: total maximum plant available water (FC-WP)
%
% Outputs:
%   - d.tranSup.tranSup: demand driven transpiration 
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
d.tranSup.tranSup(:,tix) = p.tranSup.maxRate .* sum(s.wd.pawAct,2)  ./ sum(s.wd.p_wSoilBase_wSat,2);
end