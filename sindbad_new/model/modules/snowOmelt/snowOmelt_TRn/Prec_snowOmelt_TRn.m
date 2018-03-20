function [fe,fx,d,p] = Prec_snowOmelt_TRn(f,fe,fx,s,d,p,info)
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
%           (p.SnowMelt.melt_T)
% melt_Rn   : snow melt factor of radiation [mm/MJ/m2/day]
%           (p.SnowMelt.melt_Rn)
% 
% OUTPUT
% potMelt   : potential snow melt [mm/time]
%           (fe.SnowMelt.potMelt)
% 
% NOTES: 
% 
% #########################################################################

% potential snow melt if T > 0°C
idx 				= f.Tair > 0;

tmp_mt              = p.SnowMelt.melt_T * ones(1,info.forcing.size(2));
tmp_T 				= f.Tair(idx) .* tmp_mt(idx);
tmp_mr              = p.SnowMelt.melt_Rn * ones(1,info.forcing.size(2));
tmp_Rn 				= max(f.Rn(idx) .* tmp_mr(idx), 0);

fe.SnowMelt.potMelt 		= zeros(size(f.Tair));
fe.SnowMelt.potMelt(idx)	= tmp_T + tmp_Rn;

end
