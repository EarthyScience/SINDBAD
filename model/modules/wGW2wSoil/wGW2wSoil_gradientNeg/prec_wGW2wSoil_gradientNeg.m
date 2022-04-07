function [f,fe,fx,s,d,p] = prec_wGW2wSoil_gradientNeg(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates a buffer storage that doesn't give water to the soil when the soil dries up, while the soil gives water to the buffer when the soil is
% wet but the buffer low; the buffer is only recharged by soil moisture
%
% Inputs:
%   - info                     : info.tem.model.variables.states.w.nZix.wSoil = number of soil layers
%   - p.wGW2wSoil.smax_scale   : =0.5; scale param to yield storage capacity of the buffer [mm] from smax2, bounds=[0 1]? 
%   - s.wd.p_wSoilBase_wSat    : maximum storage capacity of soil [mm]
%
% Outputs:
%   - s.wd.p_wGW2wSoil_gwmax   : maximum storage capacity of the groundwater
%     
%
% Modifies:
%
% References:
%   -
%
% Created by:
%   - Tina Trautmann (ttraut)
%
% Versions:
%   - 1.0 on 04.02.2020 (ttraut): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% PREC: storage capacity of groundwater
% index of the last soil layer
wSoilend                =  info.tem.model.variables.states.w.nZix.wSoil;

s.wd.p_wGW2wSoil_gwmax  = s.wd.p_wSoilBase_wSat(:,wSoilend) .* p.wGW2wSoil.smax_scale;

end
