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
%   - Sujan Koirala (skoirala)
%   - Nuno Carvalhais (ncarval)
%
% Versions:
%   - 1.0 on 21.11.2019
%
%% 
% we are assuming here that texture does not change with depth
% vars = {'CLAY','SAND','SILT','ORGM'};

% for vn = 1:numel(vars)
%     vari = vars{vn};
%     eval(['s.wd.p_soilTexture_' vari ' = p.soilTexture.' vari '.* info.tem.helpers.arrays.onespixzix.w.wSoil;']);
% end

s.wd.p_soilTexture_CLAY     =   p.soilTexture.CLAY .* info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_soilTexture_SAND     =   p.soilTexture.SAND .* info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_soilTexture_SILT     =   p.soilTexture.SILT .* info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_soilTexture_ORGM     =   p.soilTexture.ORGM .* info.tem.helpers.arrays.onespixzix.w.wSoil;

% p.soilTexture.CLAY =  p.soilTexture.CLAY .* info.tem.helpers.arrays.onespixzix.w.wSoil;
% p.soilTexture.SAND =  p.soilTexture.SAND .* info.tem.helpers.arrays.onespixzix.w.wSoil;
% p.soilTexture.SILT =  p.soilTexture.SILT .* info.tem.helpers.arrays.onespixzix.w.wSoil;
% p.soilTexture.ORGM =  p.soilTexture.ORGM .* info.tem.helpers.arrays.onespixzix.w.wSoil;

end