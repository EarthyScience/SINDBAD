function K = calcKSaxton1986(p,info,Theta,kSat,B)
% #########################################################################
% calculate conductivity from soil moisture 
% based on saxton 1986, equation 10
% [Alpha,Beta,K,Theta,Psi] = calcSoilParams(p,fe,info,WT)
% 
% soilm_parm    : soil moisture parameter output array
% CLAY          : clay array
% SAND          : sand array
% WT            : Psi : water tension (kPa)
%               : wilting point     : 'WP'      : WT = 1500
%               : field capacity    : 'FC'      : WT = 33
%               : saturation        : 'Sat'     : WT = 10
%               : alpha             : 'alpha'
%               : beta              : 'beta'
% 
% Reference:
% Saxton, K.E., W.J. Rawls, J.S. Romberger, and R.I. Papendick. 1986. 
% Estimating generalized soil-water characteristics from texture. 
% Soil Sci. Soc. Am. J. Vol. 50(4):1031-1036.
% http://www.bsyse.wsu.edu/saxton/soilwater/Article.htm
% #########################################################################

% CONVERT SAND AND CLAY TO PERCENTAGES
CLAY    = p.soilTexture.CLAY  .* info.tem.helpers.arrays.onespix;
SAND    = p.pSoil.SAND  .* info.tem.helpers.arrays.onespix;

% -------------------------------------------------------------------------
% WATER CONDUCTIVITY (mm/day)
K   = 2.778E-6 .*(exp(p.pSoil.p + p.pSoil.q .* SAND + ...
    (p.pSoil.r + p.pSoil.t .* SAND + p.pSoil.u .* CLAY + p.pSoil.v .*...
    CLAY .^ 2) .* (1 ./ Theta))) .* 1000 * 3600 * 24;
% -------------------------------------------------------------------------


end % function
