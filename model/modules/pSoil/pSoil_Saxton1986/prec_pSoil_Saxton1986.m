function [f,fe,fx,s,d,p] = prec_pSoil_Saxton1986(f,fe,fx,s,d,p,info)
% sets the value of soil hydraulic parameters
%
% Inputs:
%	- p.SAND/SILT/CLAY/DEPTH/+ the Saxton parameters that are in the json
%
% Outputs:
%   - p.pSoil.thetaSat/kSat/psiSat/sSat
%   - p.pSoil.thetaFC/kFC/psiFC/sFC
%   - p.pSoil.thetaWP/kWP/psiWP/sWP
%
% Modifies:
% 	- None
% 
% References:
%	- Saxton, K.E., W.J. Rawls, J.S. Romberger, and R.I. Papendick. 1986. 
% Estimating generalized soil-water characteristics from texture. 
% Soil Sci. Soc. Am. J. Vol. 50(4):1031-1036.
% http://www.bsyse.wsu.edu/saxton/soilwater/Article.htm
%
% Created by:
%   - Sujan Koirala (skoirala@bgc-jena.mpg.de)
%   - Nuno Carvalhais (ncarval@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 21.11.2019
%
%% 

% number of layers
[Alpha,Beta,kFC,thetaFC,psiFC]  = calcSoilParamsSaxton1986(p,info,p.pSoil.psiFC);
[~,~,kWP,thetaWP,psiWP]         = calcSoilParamsSaxton1986(p,info,p.pSoil.psiWP);
[~,~,kSat,thetaSat,psiSat]      = calcSoilParamsSaxton1986(p,info,p.pSoil.psiSat);

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


end % function