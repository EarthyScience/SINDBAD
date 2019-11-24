function [f,fe,fx,s,d,p] = prec_soilTexture_fixed(f,fe,fx,s,d,p,info)
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
% we are assuming here that texture does not change with depth
p.soilTexture.CLAY =  p.soilTexture.CLAY .* info.tem.helpers.arrays.onespix;
p.soilTexture.SAND =  p.soilTexture.SAND .* info.tem.helpers.arrays.onespix;
p.soilTexture.SILT =  p.soilTexture.SILT .* info.tem.helpers.arrays.onespix;
p.soilTexture.ORGM =  p.soilTexture.ORGM .* info.tem.helpers.arrays.onespix;

end % function