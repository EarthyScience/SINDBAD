function [f,fe,fx,s,d,p]=prec_rootFrac_expCvegRoot(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Precomputation for maximum root water fraction that plants can uptake from soil layers 
% according to total carbon in root (cVegRoot)
%
% Inputs:
%   - s.wd.maxRootD (from prec_rootFrac_expCvegRoot)
%   - info.tem.model.variables.states.w.soilLayerDepths
%
% Outputs:
%   - initiates s.wd.p_rootFrac_fracRoot2SoilD as ones
%
% Modifies:
% 	- s.wd.p_rootFrac_fracRoot2SoilD
%
% References:
%	-
%
% Created by:
%   - Sujan Koirala
%
% Versions:
%   - 1.0 on 28.04.2020
%				
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%s.wd.p_rootFrac_fracRoot2SoilD = info.tem.helpers.arrays.onespixzix.w.wSoil;
soilDepths = info.tem.model.variables.states.w.soilLayerDepths;
totalSoilDepth = sum(soilDepths);
s.wd.maxRootDepth = min(s.wd.maxRootD, totalSoilDepth); % maximum rootingdepth

%--> create the arrays to fill in the soil properties
s.wd.p_rootFrac_fracRoot2SoilD     =   info.tem.helpers.arrays.onespixzix.w.wSoil;
end