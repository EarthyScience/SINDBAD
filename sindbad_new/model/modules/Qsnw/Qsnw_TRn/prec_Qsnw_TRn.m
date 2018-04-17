function [f,fe,fx,s,d,p] = prec_Qsnw_TRn(f,fe,fx,s,d,p,info)
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
%           (p.Qsnw.melt_T)
% melt_Rn   : snow melt factor of radiation [mm/MJ/m2/day]
%           (p.Qsnw.melt_Rn)
% 
% OUTPUT
% potMelt   : potential snow melt [mm/time]
%           (fe.Qsnw.potMelt)
% 
% NOTES: 
% 
% #########################################################################

% potential snow melt if T > 0 deg C
idx 				= f.Tair > 0;

tmp_mt              = p.Qsnw.melt_T * info.tem.helpers.arrays.onespixtix;
tmp_T 				= f.Tair(idx) .* tmp_mt(idx);
tmp_mr              = p.Qsnw.melt_Rn * info.tem.helpers.arrays.onespixtix;
tmp_Rn 				= max(f.Rn(idx) .* tmp_mr(idx), 0);

fe.Qsnw.potMelt 		= zeros(size(f.Tair));
fe.Qsnw.potMelt(idx)	= tmp_T + tmp_Rn;

end
