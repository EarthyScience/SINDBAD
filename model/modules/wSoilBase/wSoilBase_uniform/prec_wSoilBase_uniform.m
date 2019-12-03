function [f,fe,fx,s,d,p] = prec_wSoilBase_uniform(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the soil hydraulic properties for different soil layers assuming a fixed
% vertical distribution
%
% Inputs:
%   - p.soilTexture.[SAND/SILT/CLAY/ORGM]: texture properties
%   - info.tem.model.variables.states.w.: soil layers and depths 
%   - p.pSoil.kUnsatFuncH: function handle to calculate unsaturated hydraulic conduct.
%
% Outputs:
%   - all soil hydraulic properties in s.wd.p_wSoilBase_[parameterName]
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
    error('the number of soil layers in modelStructure.json does not match with soil depths specified in wSoilBase_uniform')
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
s.wd.p_wSoilBase_kFC                =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_wSoilBase_kWP                =   info.tem.helpers.arrays.onespixzix.w.wSoil;

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
end
linScalers                          =   linspace(0,1,p.wSoilBase.nLookup);

    
%--> set the properties
for sl      =   1:nSoilLayers
    s.wd.p_wSoilBase_CLAY(:,sl)                 =   p.soilTexture.CLAY;
    s.wd.p_wSoilBase_SAND(:,sl)                 =   p.soilTexture.SAND;
    s.wd.p_wSoilBase_SILT(:,sl)                 =   p.soilTexture.SILT;
    s.wd.p_wSoilBase_ORGM(:,sl)                 =   p.soilTexture.ORGM;
    s.wd.p_wSoilBase_wFC(:,sl)                  =   p.pSoil.thetaFC .* soilDepths(sl);
    s.wd.p_wSoilBase_wWP(:,sl)                  =   p.pSoil.thetaWP .* soilDepths(sl);
    s.wd.p_wSoilBase_wSat(:,sl)                 =   p.pSoil.thetaSat .* soilDepths(sl);
    s.wd.p_wSoilBase_soilDepths(:,sl)           =   soilDepths(sl);
    s.wd.p_wSoilBase_Alpha(:,sl)                =   p.pSoil.Alpha;
    s.wd.p_wSoilBase_Beta(:,sl)                 =   p.pSoil.Beta;
    s.wd.p_wSoilBase_kSat(:,sl)                 =   p.pSoil.kSat;
    s.wd.p_wSoilBase_kFC(:,sl)                  =   p.pSoil.kFC;
    s.wd.p_wSoilBase_kWP(:,sl)                  =   p.pSoil.kWP;
    s.wd.p_wSoilBase_psiSat(:,sl)               =   p.pSoil.psiSat;
    s.wd.p_wSoilBase_psiFC(:,sl)                =   p.pSoil.psiFC;
    s.wd.p_wSoilBase_psiWP(:,sl)                =   p.pSoil.psiWP;
    s.wd.p_wSoilBase_thetaSat(:,sl)             =   p.pSoil.thetaSat;
    s.wd.p_wSoilBase_thetaFC(:,sl)              =   p.pSoil.thetaFC;
    s.wd.p_wSoilBase_thetaWP(:,sl)              =   p.pSoil.thetaWP;
    
    if info.tem.model.flags.useLookupK
        sLookup                                 =   linScalers .* s.wd.p_wSoilBase_wSat(:,sl);
%     sLookup                                 =   linspace(0,s.wd.p_wSoilBase_wSat(:,sl),p.wSoilBase.nLookup);
%         sLookup                                 =   0:s.wd.p_wSoilBase_wSat(:,sl)/p.wSoilBase.nLookup:s.wd.p_wSoilBase_wSat(:,sl);
        sLStruct.wd                             =   s.wd;
        for nL    =   1:p.wSoilBase.nLookup
            sLStruct.w.wSoil(:,sl)              =   sLookup(nL);
            tmpLookUp(:,nL)                     =   feval(p.pSoil.kUnsatFuncH,sLStruct,p,info,sl);
            % s.wd.p_wSoilBase_kLookUp(:,sl,nL)   =   feval(p.pSoil.kUnsatFuncH,sLStruct,p,info,sl);
        end
        s.wd.p_wSoilBase_kLookUp{sl}            = tmpLookUp;
    end
end
%--> get the plant available water available
s.wd.p_wSoilBase_wAWC                           =   s.wd.p_wSoilBase_wFC - s.wd.p_wSoilBase_wWP;
%--> set the make lookUp flag to false after creating the table 
if info.tem.model.flags.useLookupK
    p.wSoilBase.makeLookup                      =   0;
end
end