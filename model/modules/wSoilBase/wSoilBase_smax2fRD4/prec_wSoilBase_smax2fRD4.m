function [f,fe,fx,s,d,p] = prec_wSoilBase_smax2fRD4(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% defines the maximum soil water content of 2 soil layers 
% the first layer is a fraction (i.e. 1) of the soil depth
% the second layer is a linear combination of scaled rooting depth data from forcing 
%
% Inputs:
%   - info.tem.model.variables.states.w.: soil layers and depths 
%   - f.RDmax: maximum rooting depth from Fan et al. 2017
%   - f.RDeff: effective rooting depth from Yang et al. 2016
%   - f.SWCmax: maximum soil water capacity from Wang-Erlandsson et al. 2016
%   - f.AWC: (plant) available water capacity from Tian et al. 2019
%   - p.wSoilBase.scaleFan:     scalar parameter for the Fan et al. data
%   - p.wSoilBase.scaleYang:    scalar parameter for the Yang et al. data
%   - p.wSoilBase.scaleWang:    scalar parameter for the Wang et al. data
%   - p.wSoilBase.scaleTian:    scalar parameter for the Tian et al. data
%   - p.wSoilBase.smaxTian:     smax where the Tian data has gaps
%
% Outputs:
%   - s.wd.p_wSoilBase_RD:       the 4 scaled RD datas (pix,zix)
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
%   - 1.0 on 10.02.2020 (ttraut): 
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

%--> get the rooting depth data and scale them
s.wd.p_wSoilBase_RD(:,1)    = f.RDmax(:,1) .* p.wSoilBase.scaleFan;
s.wd.p_wSoilBase_RD(:,2)    = f.RDeff(:,1) .* p.wSoilBase.scaleYang;
s.wd.p_wSoilBase_RD(:,3)    = f.SWCmax(:,1) .* p.wSoilBase.scaleWang;

% for the Tian data, fill the NaN gaps with p.wSoilBase.smaxTian
fe.wSoilBase.AWC = f.AWC;
fe.wSoilBase.AWC(isnan(fe.wSoilBase.AWC )) = p.wSoilBase.smaxTian;
s.wd.p_wSoilBase_RD(:,4)    = fe.wSoilBase.AWC(:,1) .* p.wSoilBase.scaleTian;


%--> create the arrays to fill in the soil properties
% storages
s.wd.p_wSoilBase_wSat               =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_wFC                =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_wWP                =   info.tem.helpers.arrays.zerospixzix.w.wSoil;

%--> set the properties for each soil layer
% 1st layer
s.wd.p_wSoilBase_wSat(:,1)          =   p.wSoilBase.smax1 .* soilDepths(1);
s.wd.p_wSoilBase_wFC(:,1)           =   p.wSoilBase.smax1 .* soilDepths(1);

% 2nd layer - fill in by linaer combination of the RD data
s.wd.p_wSoilBase_wSat(:,2)          =   sum(s.wd.p_wSoilBase_RD,2);
s.wd.p_wSoilBase_wFC(:,2)           =   sum(s.wd.p_wSoilBase_RD,2);

%--> get the plant available water available
% (all the water is plant available)
s.wd.p_wSoilBase_wAWC               =   s.wd.p_wSoilBase_wSat;


end