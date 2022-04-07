function [f,fe,fx,s,d,p] = prec_wSoilBase_smax2fPFT(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% defines the maximum soil water content of 2 soil layers 
% the first layer is a fraction (i.e. 1) of the soil depth
% the second layer is defined as PFT specific parameters from forcing 
%
% Inputs:
%   - info.tem.model.variables.states.w.: soil layers and depths 
%   - f.PFT: PFT classes
%   - p.wSoilBase.smaxPFT0:     smax for PFT class 0 -> scalar*soilDepth(=1000)
%   - p.wSoilBase.smaxPFT1:     smax for PFT class 1
%   - p.wSoilBase.smaxPFT2:     smax for PFT class 2
%   - p.wSoilBase.smaxPFT3:     smax for PFT class 3
%   - p.wSoilBase.smaxPFT4:     smax for PFT class 4
%   - p.wSoilBase.smaxPFT5:     smax for PFT class 5
%   - p.wSoilBase.smaxPFT6:     smax for PFT class 6
%   - p.wSoilBase.smaxPFT7:     smax for PFT class 7
%   - p.wSoilBase.smaxPFT8:     smax for PFT class 8
%   - p.wSoilBase.smaxPFT9:     smax for PFT class 9
%   - p.wSoilBase.smaxPFT10:     smax for PFT class 10
%   - p.wSoilBase.smaxPFT11:     smax for PFT class 11
%
% Outputs:
%   - s.wd.p_wSoilBase_smaxPFT:  the combined parameters (pix,1)
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
%   - 1.0 on 10.09.2021 (ttraut): 
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

%--> get the PFT data & assign parameters
tmp_classes = unique(f.PFT);
s.wd.p_wSoilBase_smaxPFT =  info.tem.helpers.arrays.onespix;
for nC=1:length(tmp_classes)
    nPFT = tmp_classes(nC);
    p_tmp = eval(char(['p.wSoilBase.smaxPFT' num2str(nPFT)]));
    s.wd.p_wSoilBase_smaxPFT(f.PFT==nPFT,1) = soilDepths(2).*  p_tmp;    % 
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

% 2nd layer - fill in by linaer combination of the RD data
s.wd.p_wSoilBase_wSat(:,2)          =   s.wd.p_wSoilBase_smaxPFT;
s.wd.p_wSoilBase_wFC(:,2)           =   s.wd.p_wSoilBase_smaxPFT;

%--> get the plant available water available
% (all the water is plant available)
s.wd.p_wSoilBase_wAWC               =   s.wd.p_wSoilBase_wSat;


end