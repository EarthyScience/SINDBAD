function [f,fe,fx,s,d,p]=prec_rootFrac_k2Layer(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the maximum fraction of water that root can uptake from soil layers
% as calibration parameter, hard coded for 2 soil layers
%
% Inputs:
%   - info.tem.model.variables.states.w.: soil layers and depths 
%   - p.rootFrac.k1   : fraction of upper soil layer available for transpiration
%   - p.rootFrac.k2   : fraction of lower soil layer available for transpiration 
%
% Outputs:
%   - s.wd.p_rootFrac_fracRoot2SoilD as nPix,nZix for wSoil
%
% Modifies:
% 	- 
% 
% References:
%	- 
%
% Created by:
%   - Tina Trautmann (ttraut)
%
% Versions:
%   - 1.0 on 09.01.2020
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 

%--> get the soil thickness and root distribution information from input
nSoilLayers                   =   info.tem.model.variables.states.w.nZix.wSoil;
soilDepths                    =   info.tem.model.variables.states.w.soilLayerDepths;

%--> check if the number of soil layers and number of elements in soil
%thickness arrays are the same and are equal to 2
if numel(soilDepths)                ~=  nSoilLayers &&  numel(soilDepths) ~= 2
    error(['prec_rootFrac_k2Layer: the number of soil layers in modelStructure.json does not match with soil depths specified. This approach needs 2 soil layers.'])
end

k1RootFrac                    =   info.tem.helpers.arrays.onespix .* p.rootFrac.k1; % the fraction of water that a root can uptake from the 1st soil layer
k2RootFrac                    =   info.tem.helpers.arrays.onespix .* p.rootFrac.k2; % the fraction of water that a root can uptake from the 1st soil layer

%--> create the arrays to fill in the soil properties
s.wd.p_rootFrac_fracRoot2SoilD     =   info.tem.helpers.arrays.onespixzix.w.wSoil;
%--> set the properties
% 1st Layer
s.wd.p_rootFrac_fracRoot2SoilD(:,1)  =   s.wd.p_rootFrac_fracRoot2SoilD(:,1) .* k1RootFrac;
% 2nd Layer
s.wd.p_rootFrac_fracRoot2SoilD(:,2)  =   s.wd.p_rootFrac_fracRoot2SoilD(:,2) .* k2RootFrac;

end