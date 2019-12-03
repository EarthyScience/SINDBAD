function [f,fe,fx,s,d,p] = prec_pSoil_Saxton2006(f,fe,fx,s,d,p,info)
% sets the value of soil hydraulic parameters
%
% Inputs:
%    - p.SAND/SILT/CLAY/+ the Saxton parameters that are in the json
%
% Outputs:
%   - p.pSoil.thetaSat/kSat/psiSat/sSat
%   - p.pSoil.thetaFC/kFC/psiFC/sFC
%   - p.pSoil.thetaWP/kWP/psiWP/sWP
%
% Modifies:
%     - None
% 
% References:
%    - Saxton, K.E., W.J. Rawls, J.S. Romberger, and R.I. Papendick. 1986. 
% Estimating generalized soil-water characteristics from texture. 
% Soil Sci. Soc. Am. J. Vol. 50(4):1031-1036.
% http://www.bsyse.wsu.edu/saxton/soilwater/Article.htm
%
% Created by:
%   - Sujan Koirala (skoirala)
%   - Nuno Carvalhais (ncarval)
%
% Versions:
%   - 1.0 on 21.11.2019
%
%% 
% we are assuming here that texture does not change with depth

% number of layers
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

for sl      =   1:nSoilLayers
    [Alpha,Beta,kSat,thetaSat,psiSat,kFC,thetaFC,psiFC,kWP,thetaWP,psiWP] = calcSoilParamsSaxton2006(s,p,info,sl);
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