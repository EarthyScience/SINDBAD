function [f,fe,fx,s,d,p] = prec_wSoilBase_uniform(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% distributes the soil hydraulic properties for different soil layers assuming an uniform
% vertical distribution of all soil properties
%
% Inputs:
%   - s.wd.p_soilTexture_[SAND/SILT/CLAY/ORGM]: texture properties (nPix, nZix)
%   - info.tem.model.variables.states.w.: soil layers and depths 
%   - p.pSoil.kUnsatFuncH: function handle to calculate unsaturated hydraulic conduct.
%   - info.tem.model.flags.useLookupK: flag for creating lookup table (modelRun.json)
%
% Outputs:
%   - all soil hydraulic properties in s.wd.p_wSoilBase_[parameterName] (nPix, nTix)
%
% Modifies:
% 	- p.wSoilBase.makeLookup: to switch on/off the creation of lookup table of 
%     unsaturated hydraulic conductivity
%
% References:
%   - 
%
% Created by:
%   - Sujan Koirala (skoirala)
%   - Nuno Carvalhais (ncarval)
%
% Versions:
%   - 1.0 on 18.11.2019 (skoirala): clean up and consistency
%   - 1.1 on 03.12.2019 (skoirala): handling potentail vertical distribution of soil texture
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
%--> get the soil thickness and root distribution information from input
nSoilLayers                         =   info.tem.model.variables.states.w.nZix.wSoil;
soilDepths                          =   info.tem.model.variables.states.w.soilLayerDepths;
s.wd.p_wSoilBase_soilDepths         =   soilDepths;

%--> check if the number of soil layers and number of elements in soil
%thickness arrays are the same
if numel(soilDepths)                ~=  nSoilLayers
    error(['prec_wSoilBase_uniform: the number of soil layers in modelStructure.json does not match with soil depths specified'])
end

%--> create the arrays to fill in the soil properties
s.wd.p_wSoilBase_nsoilLayers        =   nSoilLayers;
s.wd.p_wSoilBase_CLAY               =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_SAND               =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_SILT               =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_ORGM               =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_soilDepths         =   info.tem.helpers.arrays.onespixzix.w.wSoil;

% storages
s.wd.p_wSoilBase_wFC                =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_wWP                =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_wSat               =   info.tem.helpers.arrays.onespixzix.w.wSoil;

% hydraulic conductivities
s.wd.p_wSoilBase_kSat               =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_logkSat            =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_kFC                =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_kWP                =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_kPow               =   info.tem.helpers.arrays.onespixzix.w.wSoil;

% matric potentials
s.wd.p_wSoilBase_psiSat             =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_psiFC              =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_psiWP              =   info.tem.helpers.arrays.onespixzix.w.wSoil;

% moisture contents
s.wd.p_wSoilBase_thetaSat           =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_thetaFC            =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_thetaWP            =   info.tem.helpers.arrays.onespixzix.w.wSoil;

% retention coefficients
s.wd.p_wSoilBase_Alpha              =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_Beta               =   info.tem.helpers.arrays.onespixzix.w.wSoil;

%--> create the information for look up table
p.wSoilBase.makeLookup              =   1;

if info.tem.model.flags.useLookupK
    tmpLookUp                       =   repmat(info.tem.helpers.arrays.onespix,1,p.wSoilBase.nLookup);
    s.wd.p_wSoilBase_kLookUp        =   cell(nSoilLayers,1);
    % s.wd.p_wSoilBase_kLookUp        =   repmat(info.tem.helpers.arrays.onespixzix.w.wSoil,1,1,p.wSoilBase.nLookup);
    sLStruct                        =   struct;
    sLStruct.w.wSoil                =   info.tem.helpers.arrays.onespixzix.w.wSoil;
    linScalers                      =   linspace(0,1,p.wSoilBase.nLookup);
end

%--> set the properties for each soil layer
for sl      =   1:nSoilLayers
    s.wd.p_wSoilBase_CLAY(:,sl)                 =   s.wd.p_soilTexture_CLAY(:,sl);
    s.wd.p_wSoilBase_SAND(:,sl)                 =   s.wd.p_soilTexture_SAND(:,sl);
    s.wd.p_wSoilBase_SILT(:,sl)                 =   s.wd.p_soilTexture_SILT(:,sl);
    s.wd.p_wSoilBase_ORGM(:,sl)                 =   s.wd.p_soilTexture_ORGM(:,sl);
    s.wd.p_wSoilBase_wFC(:,sl)                  =   s.wd.p_pSoil_thetaFC(:,sl) .* soilDepths(sl);
    s.wd.p_wSoilBase_wWP(:,sl)                  =   s.wd.p_pSoil_thetaWP(:,sl) .* soilDepths(sl);
    s.wd.p_wSoilBase_wSat(:,sl)                 =   s.wd.p_pSoil_thetaSat(:,sl) .* soilDepths(sl);
    s.wd.p_wSoilBase_soilDepths(:,sl)           =   soilDepths(sl);
    s.wd.p_wSoilBase_Alpha(:,sl)                =   s.wd.p_pSoil_Alpha(:,sl);
    s.wd.p_wSoilBase_Beta(:,sl)                 =   s.wd.p_pSoil_Beta(:,sl);
    s.wd.p_wSoilBase_kSat(:,sl)                 =   s.wd.p_pSoil_kSat(:,sl);
    s.wd.p_wSoilBase_kSat(:,sl)                 =   s.wd.p_pSoil_kSat(:,sl);
    s.wd.p_wSoilBase_kFC(:,sl)                  =   s.wd.p_pSoil_kFC(:,sl);
    s.wd.p_wSoilBase_kWP(:,sl)                  =   s.wd.p_pSoil_kWP(:,sl);
    s.wd.p_wSoilBase_psiSat(:,sl)               =   s.wd.p_pSoil_psiSat(:,sl);
    s.wd.p_wSoilBase_psiFC(:,sl)                =   s.wd.p_pSoil_psiFC(:,sl);
    s.wd.p_wSoilBase_psiWP(:,sl)                =   s.wd.p_pSoil_psiWP(:,sl);
    s.wd.p_wSoilBase_thetaSat(:,sl)             =   s.wd.p_pSoil_thetaSat(:,sl);
    s.wd.p_wSoilBase_thetaFC(:,sl)              =   s.wd.p_pSoil_thetaFC(:,sl);
    s.wd.p_wSoilBase_thetaWP(:,sl)              =   s.wd.p_pSoil_thetaWP(:,sl);
    Beta                                        =   s.wd.p_wSoilBase_Beta(:,sl);
    lambda                                      =   1 ./ Beta;
    s.wd.p_wSoilBase_kPow(:,sl)                 =   3 + (2 ./ lambda);
    s.wd.p_wSoilBase_logkSat(:,sl)              =   log(s.wd.p_wSoilBase_logkSat(:,sl));
    
    if info.tem.model.flags.useLookupK
        sLookup                                 =   linScalers .* s.wd.p_wSoilBase_wSat(:,sl);
        sLStruct.wd                             =   s.wd;
        for nL    =   1:p.wSoilBase.nLookup
            sLStruct.w.wSoil(:,sl)              =   sLookup(nL);
            tmpLookUp(:,nL)                     =   feval(p.pSoil.kUnsatFuncH,sLStruct,p,info,sl);
        end
        s.wd.p_wSoilBase_kLookUp{sl}            = tmpLookUp;
    end
end
%--> get the plant available water capacity
s.wd.p_wSoilBase_wAWC                           =   s.wd.p_wSoilBase_wFC - s.wd.p_wSoilBase_wWP;
%--> set the make lookUp flag to false after creating the table 
if info.tem.model.flags.useLookupK
    p.wSoilBase.makeLookup                      =   0;
end
end