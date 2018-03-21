function [fe,fx,d,p] = prec_snowOmelt_TRn(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: precompute the potential snow melt based on temperature and net radiation
% 
% REFERENCES: ??
% 
% CONTACT	: ttraut
% 
% INPUT
% Tair      : temperature [C]
%           (f.Tair)
% Rn        : net radiation [MJ/m2/day]
%           (f.Rn)
% melt_T    : snow melt factor of temperature [mm/C/day]
%           (p.snowOmelt.melt_T)
% melt_Rn   : snow melt factor of radiation [mm/MJ/m2/day]
%           (p.snowOmelt.melt_Rn)
% 
% OUTPUT
% potMelt   : potential snow melt [mm/time]
%           (fe.snowOmelt.potMelt)
% 
% NOTES: 
% 
% #########################################################################

% potential snow melt if T > 0°C
idx 				= f.Tair > 0;

tmp_mt              = p.snowOmelt.melt_T * ones(1,info.forcing.size(2));
tmp_T 				= f.Tair(idx) .* tmp_mt(idx);
tmp_mr              = p.snowOmelt.melt_Rn * ones(1,info.forcing.size(2));
tmp_Rn 				= max(f.Rn(idx) .* tmp_mr(idx), 0);

fe.snowOmelt.potMelt 		= zeros(size(f.Tair));
fe.snowOmelt.potMelt(idx)	= tmp_T + tmp_Rn;

end
