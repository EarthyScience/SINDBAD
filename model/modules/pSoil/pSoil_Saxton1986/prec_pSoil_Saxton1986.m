function [f,fe,fx,s,d,p] = prec_pSoil_Saxton1986(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% assigns the soil hydraulic properties based on Saxton, 1986 to s.wd.p_pSoil_
%
% Inputs:
%   - info
%   - calcSoilParamsSaxton1986: function to calculate hydraulic properties 
%	    - s.wd.p_soilTexture_[CLAY/SAND]
%       - p.pSoil.: texture-based Saxton parameters 
% 
% Outputs:
%   - s.wd.p_pSoil_[Alpha/Beta]: properties of moisture-retention curves
%   - hydraulic conductivity (k), matric potention (psi) and porosity
%   (theta) at saturation (Sat), field capacity (FC), and wilting point
%   (WP)
%       - s.wd.p_pSoil_thetaSat/kSat/psiSat/sSat
%       - s.wd.p_pSoil_thetaFC/kFC/psiFC/sFC
%       - s.wd.p_pSoil_thetaWP/kWP/psiWP/sWP
%
% Modifies:
%   - None
% 
% References:
%    - Saxton, K.E., W.J. Rawls, J.S. Romberger, and R.I. Papendick. 1986. 
%       Estimating generalized soil-water characteristics from texture. 
%       Soil Sci. Soc. Am. J. Vol. 50(4):1031-1036.
%       http://www.bsyse.wsu.edu/saxton/soilwater/Article.htm
%
% Created by:
%   - Sujan Koirala (skoirala)
%   - Nuno Carvalhais (ncarval)
%
% Versions:
%   - 1.0 on 21.11.2019
%   - 1.1 on 03.12.2019 (skoirala): handling potentail vertical distribution of soil texture
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
%--> number of layers and creation of arrays
nSoilLayers                         =   info.tem.model.variables.states.w.nZix.wSoil;
s.wd.p_pSoil_Alpha                  =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_pSoil_Beta                   =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_pSoil_kFC                    =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_pSoil_thetaFC                =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_pSoil_psiFC                  =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_pSoil_kWP                    =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_pSoil_thetaWP                =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_pSoil_psiWP                  =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_pSoil_kSat                   =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_pSoil_thetaSat               =   info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_pSoil_psiSat                 =   info.tem.helpers.arrays.onespixzix.w.wSoil;

%--> calculate and set the soil hydraulic properties for each layer
for sl      =   1:nSoilLayers
    [Alpha,Beta,kFC,thetaFC,psiFC]  =   calcSoilParamsSaxton1986(s,p,info,sl,p.pSoil.psiFC);
    [~,~,kWP,thetaWP,psiWP]         =   calcSoilParamsSaxton1986(s,p,info,sl,p.pSoil.psiWP);
    [~,~,kSat,thetaSat,psiSat]      =   calcSoilParamsSaxton1986(s,p,info,sl,p.pSoil.psiSat);
    s.wd.p_pSoil_Alpha(:,sl)        =   Alpha;
    s.wd.p_pSoil_Beta(:,sl)         =   Beta;
    s.wd.p_pSoil_kFC(:,sl)          =   kFC;
    s.wd.p_pSoil_thetaFC(:,sl)      =   thetaFC;
    s.wd.p_pSoil_psiFC(:,sl)        =   psiFC;
    s.wd.p_pSoil_kWP(:,sl)          =   kWP;
    s.wd.p_pSoil_thetaWP(:,sl)      =   thetaWP;
    s.wd.p_pSoil_psiWP(:,sl)        =   psiWP;
    s.wd.p_pSoil_kSat(:,sl)         =   kSat;
    s.wd.p_pSoil_thetaSat(:,sl)     =   thetaSat;
    s.wd.p_pSoil_psiSat(:,sl)       =   psiSat;
end

p.pSoil.kUnsatFuncH  = str2func(p.pSoil.kUnsatFunc);

end