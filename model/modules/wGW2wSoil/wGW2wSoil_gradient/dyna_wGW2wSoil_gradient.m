function [f,fe,fx,s,d,p] = wGW2wSoil_gradient(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates wGW  storage that gives water to the soil when the soil dries up, while the soil gives water to the wGW when the soil is
% wet but the wGW low; the wGW is only recharged by soil moisture
%
% Inputs:
%   - info                      : info.tem.model.variables.states.w.nZix.wSoil = number of soil layers
%   - p.wGW2wSoil.maxFlux       : maximum flux between wSoil and wGW [mm/d]
%   - s.wd.p_wGW2wSoil_gwmax    : maximum storage capacity of the groundwater
%   - s.wd.p_wSoilBase_wSat     : maximum storage capacity of soil [mm]
%
% Outputs:
%   - fx.GW2Soil                :  flux between wGW and wSoil [mm/time], positive to soil, negative to gw
%   - fe.wGW2wSoil.potFlux      :  potentital flux between wSoil and wGW, depending on the gradient and p.wGW2wSoil.maxFlux [mm]
%
% Modifies:
% 	- s.w.wSoil
%   - s.w.wGW 
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

% zix of last soil layer
wSoilend                =  info.tem.model.variables.states.w.nZix.wSoil;

% gradient between wGW and wSoil
tmp_gradient = s.w.wGW ./ s.wd.p_wGW2wSoil_gwmax - s.w.wSoil(:,wSoilend) ./ s.wd.p_wSoilBase_wSat(:,wSoilend); % the sign of the gradient gives direction of flow: positive=flux to soil; negative=flux to gw

% scale gradient with pot flux rate to get pot flux
fe.wGW2wSoil.potFlux(:,tix) = tmp_gradient .* p.wGW2wSoil.maxFlux; % need to make sure that the flux does not overflow or underflow storages

% adjust the pot flux to what is there
fx.GW2Soil(:,tix)  = min(fe.wGW2wSoil.potFlux(:,tix), min(s.w.wGW, s.wd.p_wSoilBase_wSat(:,wSoilend) - s.w.wSoil(:,wSoilend)));
fx.GW2Soil(:,tix)  = max(fx.GW2Soil(:,tix), max(-s.w.wSoil(:,wSoilend), -(s.wd.p_wGW2wSoil_gwmax - s.w.wGW))); % use here the fx.GW2Soil from above! 

% update water pools
s.w.wSoil(:,wSoilend)   = s.w.wSoil(:,wSoilend) + fx.GW2Soil(:,tix);
s.w.wGW                 = s.w.wGW - fx.GW2Soil(:,tix);

end
