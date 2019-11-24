function [f,fe,fx,s,d,p] = prec_wSoilBase_uniform(f,fe,fx,s,d,p,info)
% sets the value of soil hydraulic parameters
%
% Inputs:
%   - p.pSoil.thetaSat/kSat/psiSat/sSat
%   - p.pSoil.thetaFC/kFC/psiFC/sFC
%   - p.pSoil.thetaWP/kWP/psiWP/sWP
%
% Outputs:
%   - same as inputs per layer of soil depth in s.wd.p_wSoilBase_(parameter_name)
%
% Modifies:
% 	- None
% 
% References:
%	- 
%
% Created by:
%   - Sujan Koirala (skoirala@bgc-jena.mpg.de)
%   - Nuno Carvalhais (ncarval@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 21.11.2019
%
%% 

%--> get the soil thickness and root distribution information from input
nSoilLayers                         =   info.tem.model.variables.states.w.nZix.wSoil;
soilDepths                          =   info.tem.model.variables.states.w.soilLayerDepths;
s.wd.p_wSoilBase_soilDepths         =   soilDepths;
fracRoot2SoilD                      =   info.tem.model.variables.states.w.fracRoot2SoilD;

%--> check if the number of soil layers and number of elements in soil
%thickness arrays are the same
if numel(soilDepths)                ~=  nSoilLayers
    error('the number of soil layers in modelStructure.json does not match with soil depths specified in wSoilBase_uniform')
end

%--> create the arrays to fill in the soil properties
s.wd.p_wSoilBase_nsoilLayers        =   nSoilLayers;
s.wd.p_wSoilBase_CLAY               =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_SAND               =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_SILT               =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_ORGM               =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_fracRoot2SoilD     =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_soilDepths         =   info.tem.helpers.arrays.onespixzix.w.wSoil;

% storages
s.wd.p_wSoilBase_wFC                =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_wWP                =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_wSat               =   info.tem.helpers.arrays.onespixzix.w.wSoil;

% hydraulic conductivities
s.wd.p_wSoilBase_kSat               =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_kFC                =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_kWP                =   info.tem.helpers.arrays.onespixzix.w.wSoil;

s.wd.p_wSoilBase_psiSat             =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_psiFC              =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_psiWP              =   info.tem.helpers.arrays.onespixzix.w.wSoil;

% matric potentials
s.wd.p_wSoilBase_thetaSat           =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_thetaFC            =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_thetaWP            =   info.tem.helpers.arrays.onespixzix.w.wSoil;

% retention coefficients
s.wd.p_wSoilBase_Alpha              =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_Beta               =   info.tem.helpers.arrays.onespixzix.w.wSoil;

%--> set the properties
for sl = 1:nSoilLayers
    s.wd.p_wSoilBase_CLAY(:,sl)             =   p.soilTexture.CLAY;
    s.wd.p_wSoilBase_SAND(:,sl)             =   p.soilTexture.SAND;
    s.wd.p_wSoilBase_SILT(:,sl)             =   p.soilTexture.SILT;
    s.wd.p_wSoilBase_ORGM(:,sl)             =   p.soilTexture.ORGM;
    s.wd.p_wSoilBase_wFC(:,sl)              =   p.pSoil.thetaFC .* soilDepths(sl);
    s.wd.p_wSoilBase_wWP(:,sl)              =   p.pSoil.thetaWP .* soilDepths(sl);
    s.wd.p_wSoilBase_wSat(:,sl)             =   p.pSoil.thetaSat .* soilDepths(sl);
    s.wd.p_wSoilBase_soilDepths(:,sl)       =   soilDepths(sl);
    s.wd.p_wSoilBase_fracRoot2SoilD(:,sl)   =   s.wd.p_wSoilBase_fracRoot2SoilD(:,sl) .* fracRoot2SoilD(sl);
    s.wd.p_wSoilBase_Alpha(:,sl)            =   p.pSoil.Alpha;
    s.wd.p_wSoilBase_Beta(:,sl)             =   p.pSoil.Beta;
    s.wd.p_wSoilBase_kSat(:,sl)             =   p.pSoil.kSat;
    s.wd.p_wSoilBase_kFC(:,sl)              =   p.pSoil.kFC;
    s.wd.p_wSoilBase_kWP(:,sl)              =   p.pSoil.kWP;
    s.wd.p_wSoilBase_psiSat(:,sl)           =   p.pSoil.psiSat;
    s.wd.p_wSoilBase_psiFC(:,sl)            =   p.pSoil.psiFC;
    s.wd.p_wSoilBase_psiWP(:,sl)            =   p.pSoil.psiWP;
    s.wd.p_wSoilBase_thetaSat(:,sl)         =   p.pSoil.thetaSat;
    s.wd.p_wSoilBase_thetaFC(:,sl)          =   p.pSoil.thetaFC;
    s.wd.p_wSoilBase_thetaWP(:,sl)          =   p.pSoil.thetaWP;
end

%--> get the plant available water available
s.wd.p_wSoilBase_wAWC                       =   s.wd.p_wSoilBase_wFC - s.wd.p_wSoilBase_wWP;

end %function