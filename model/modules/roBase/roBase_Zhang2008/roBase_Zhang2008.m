function [f,fe,fx,s,d,p] = roBase_Zhang2008(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% computes baseflow from a linear ground water storage
%
% Inputs:
%   -   p.roBase.bc: baseflow coefficient [1/time]
%
% Outputs:
%   -   fx.roBase: base flow [mm/time]
%
% Modifies:
%   -   s.w.wGW: groundwater storage [mm]
%
% References:
%   -   Zhang, Y. Q., Chiew, F. H. S., Zhang, L., Leuning, R., & Cleugh, H. A. (2008). 
%       Estimating catchment evaporation and runoff using MODIS leaf area index and the Penman‐Monteith equation. 
%       Water Resources Research, 44(10).
%
% Created by:
%   -   Martin Jung (mjung)
%
% Versions:
%   -   1.0 on 18.11.2019 (ttraut): cleaned up the code
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
% simply assume that a fraction of the GWstorage is baseflow
fx.roBase(:,tix) = p.roBase.bc .* s.w.wGW;
% update the GW pool
s.w.wGW = s.w.wGW - fx.roBase(:,tix);
end
