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
[Alpha,Beta,kSat,thetaSat,psiSat,kFC,thetaFC,psiFC,kWP,thetaWP,psiWP] = calcSoilParamsSaxton2006(p,info);
% [Alpha,Beta,kFC,thetaFC,psiFC]  = calcSoilParamsSaxton2006(p,fe,info,p.pSoil.psiFC);
% [~,~,kWP,thetaWP,psiWP]         = calcSoilParamsSaxton2006(p,fe,info,p.pSoil.psiWP);
% [~,~,kSat,thetaSat,psiSat]      = calcSoilParamsSaxton2006(p,fe,info,p.pSoil.psiSat);

p.pSoil.Alpha       = Alpha;
p.pSoil.Beta        = Beta;

p.pSoil.kFC         = kFC;
p.pSoil.thetaFC     = thetaFC;
p.pSoil.psiFC       = psiFC;

p.pSoil.kWP         = kWP;
p.pSoil.thetaWP     = thetaWP;
p.pSoil.psiWP       = psiWP;

p.pSoil.kSat        = kSat;
p.pSoil.thetaSat    = thetaSat;
p.pSoil.psiSat      = psiSat;

p.pSoil.kUnsatFuncH  = str2func(p.pSoil.kUnsatFunc);

end