function [f,fe,fx,s,d,p] = prec_snowMelt_TRn(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% precompute the potential snow melt based on temperature and net radiation
% on days with Tair > 0degC
%
% Inputs:
% 	- f.Tair:   temperature [C]
% 	- f.Rn:     net radiation [MJ/m2/day]
% 	- p.snowMelt.melt_T: snow melt factor of temperature [mm/C/day]
% 	- p.snowMelt.melt_Rn: snow melt factor of radiation [mm/MJ/m2/day]
%	- info structure
%
% Outputs:
%   - fe.snowMelt.potMelt: potential snow melt [mm/time]
%
% Modifies:
% 	- 
%
% References:
%	- 
%
% Created by:
%   - Tina Trautmann (ttraut)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
% potential snow melt if T > 0 deg C
idx 				= f.Tair > 0;

tmp_mt              = p.snowMelt.melt_T .* info.tem.helpers.arrays.onespixtix;
tmp_T 				= f.Tair(idx) .* tmp_mt(idx);
tmp_mr              = p.snowMelt.melt_Rn .* info.tem.helpers.arrays.onespixtix;
tmp_Rn 				= max(f.Rn(idx) .* tmp_mr(idx), 0);

fe.snowMelt.potMelt 		= zeros(size(f.Tair));
fe.snowMelt.potMelt(idx)	= tmp_T + tmp_Rn;

end
