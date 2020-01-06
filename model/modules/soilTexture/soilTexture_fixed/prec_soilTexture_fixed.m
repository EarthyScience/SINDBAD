function [f,fe,fx,s,d,p] = prec_soilTexture_fixed(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the soil texture properties as constant
%
% Inputs:
%	- p.soilTexture.SAND/SILT/CLAY/ORGM
%
% Outputs:
%   - s.wd.p_soilTexture_SAND/SILT/CLAY/ORGM
%
% Modifies:
% 	- None
% 
% References:
%	- 
%
% Notes:
%   - texture does not change with space and depth
% 
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 21.11.2019
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
s.wd.p_soilTexture_CLAY     =   p.soilTexture.CLAY .* info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_soilTexture_SAND     =   p.soilTexture.SAND .* info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_soilTexture_SILT     =   p.soilTexture.SILT .* info.tem.helpers.arrays.onespixzix.w.wSoil;
s.wd.p_soilTexture_ORGM     =   p.soilTexture.ORGM .* info.tem.helpers.arrays.onespixzix.w.wSoil;
end