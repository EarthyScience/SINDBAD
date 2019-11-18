function [f,fe,fx,s,d,p] = prec_Qsnow_TRn(f,fe,fx,s,d,p,info)
% #########################################################################
% precompute the potential snow melt based on temperature and net radiation
% on days with Tair > 0°C
%
% Inputs:
% 	- f.Tair:   temperature [C]
% 	- f.Rn:     net radiation [MJ/m2/day]
% 	- p.Qsnow.melt_T: snow melt factor of temperature [mm/C/day]
% 	- p.Qsnow.melt_Rn: snow melt factor of radiation [mm/MJ/m2/day]
%	- info structure
%
% Outputs:
%   - fe.Qsnow.potMelt: potential snow melt [mm/time]
%
% Modifies:
% 	- 
%
% References:
%	- 
%
% Created by:
%   - Tina Trautmann (ttraut@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%
%%
% #########################################################################

% potential snow melt if T > 0 deg C
idx 				= f.Tair > 0;

tmp_mt              = p.Qsnow.melt_T * info.tem.helpers.arrays.onespixtix;
tmp_T 				= f.Tair(idx) .* tmp_mt(idx);
tmp_mr              = p.Qsnow.melt_Rn * info.tem.helpers.arrays.onespixtix;
tmp_Rn 				= max(f.Rn(idx) .* tmp_mr(idx), 0);

fe.Qsnow.potMelt 		= zeros(size(f.Tair));
fe.Qsnow.potMelt(idx)	= tmp_T + tmp_Rn;

end
