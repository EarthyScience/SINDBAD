function [f,fe,fx,s,d,p] = prec_wSoilBase_smax2Layer(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% defines the maximum soil water content of 2 soil layers as fraction of
% the soil depth defined in the ModelStructure.json
% based on the older version of the Pre-Tokyo Model
%
% Inputs:
%   - info.tem.model.variables.states.w.: soil layers and depths 
%
% Outputs:
%   - s.wd.p_wSoilBase_wSat:     wSat = smax for 2 soil layers
%   - s.wd.p_wSoilBase_wFC :     = s.wd.p_wSoilBase_wSat
%   - s.wd.p_wSoilBase_wAWC:     = s.wd.p_wSoilBase_wSat
%   - s.wd.p_wSoilBase_wWP:      wilting point set to zero for all layers
%   - s.wd.p_wSoilBase_soilDepths  
%   - s.wd.p_wSoilBase_nsoilLayers 
%
% Modifies:
% 	- 
%
% References:
%   - 
%
% Created by:
%   - Tina Trautmann (ttraut)
%
% Versions:
%   - 1.0 on 09.01.2020 (ttraut): clean up and consistency
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
%--> get the soil thickness and root distribution information from input
nSoilLayers                         =   info.tem.model.variables.states.w.nZix.wSoil;
soilDepths                          =   info.tem.model.variables.states.w.soilLayerDepths;
s.wd.p_wSoilBase_soilDepths         =   soilDepths;
s.wd.p_wSoilBase_nsoilLayers        =   nSoilLayers;

%--> check if the number of soil layers and number of elements in soil
%thickness arrays are the same and are equal to 2
if numel(soilDepths)                ~=  nSoilLayers &&  numel(soilDepths) ~= 2
    error(['prec_wSoilBase_smax2Layer: the number of soil layers in modelStructure.json does not match with soil depths specified. This approach needs 2 soil layers.'])
end

%--> create the arrays to fill in the soil properties
% storages
s.wd.p_wSoilBase_wSat               =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_wFC                =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_wWP                =   info.tem.helpers.arrays.zerospixzix.w.wSoil;

%--> set the properties for each soil layer
% 1st layer
s.wd.p_wSoilBase_wSat(:,1)          =   p.wSoilBase.smax1 .* soilDepths(1);
s.wd.p_wSoilBase_wFC(:,1)           =   p.wSoilBase.smax1 .* soilDepths(1);

% 2nd layer
s.wd.p_wSoilBase_wSat(:,2)          =   p.wSoilBase.smax2 .* soilDepths(2);
s.wd.p_wSoilBase_wFC(:,2)           =   p.wSoilBase.smax2 .* soilDepths(2);

%--> get the plant available water available
% (all the water is plant available)
s.wd.p_wSoilBase_wAWC               =   s.wd.p_wSoilBase_wSat;


end