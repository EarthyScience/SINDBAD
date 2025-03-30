function [f,fe,fx,s,d,p] = prec_soilTexture_forcing(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the soil texture properties from input
%
% Inputs:
%	- f.SAND/SILT/CLAY/ORGM
%
% Outputs:
%   - s.wd.p_soilTexture_SAND/SILT/CLAY/ORGM
%
% Modifies:
% 	- None
% 
% References:
%	- 
%
% Notes:
%   - if the input has same number of layers and wSoil, then sets the properties per layer
%   - if not, then sets the average of all as the fixed property of all layers
% 
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 21.11.2019
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
%--> get the number of soil layers from model structure and create arrays for soil
%   texture properties
nSoilLayers                         =   info.tem.model.variables.states.w.nZix.wSoil;
s.wd.p_soilTexture_CLAY             =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_soilTexture_SAND             =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_soilTexture_SILT             =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_soilTexture_ORGM             =   info.tem.helpers.arrays.onespixzix.w.wSoil;

%--> set the properties
vars = {'CLAY','SAND','SILT','ORGM'};
for vn = 1:numel(vars)
    vari = vars{vn};
    if size(f.(vari),2) == nSoilLayers
        dat = f.(vari);
        dispMsg = [pad('prec_soilTexture_forcing',20) ' |  the vertical profile of soil texture properties and discretization match. Using the observed profile.'];

    else
        datTmp                      =   mean(f.(vari),2);
        dat                         =   repmat(datTmp,1,nSoilLayers);
        dispMsg= [pad('prec_soilTexture_forcing',20) ' |  the vertical profile of soil texture properties do not match the discretization of soil layers in modelStructure.json. Using average of all layers for setting soil properties'];
    end        
    for sl      =   1:nSoilLayers
        eval(['s.wd.p_soilTexture_' vari '(:,sl)  = dat(:,sl);']);
    end
end
disp(dispMsg)
end