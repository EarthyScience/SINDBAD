function [f,fe,fx,s,d,p] = prec_Qsnow_TRn(f,fe,fx,s,d,p,info)
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
%           (p.Qsnow.melt_T)
% melt_Rn   : snow melt factor of radiation [mm/MJ/m2/day]
%           (p.Qsnow.melt_Rn)
%
% OUTPUT
% potMelt   : potential snow melt [mm/time]
%           (fe.Qsnow.potMelt)
%
% NOTES:
%
% #########################################################################

% potential snow melt if T > 0 deg C
idx 				= f.Tair > 0;

tmp_mt              = p.Qsnow.melt_T * info.tem.helpers.arrays.onespixtix;
tmp_T 				      = f.Tair(idx) .* tmp_mt(idx);
tmp_mr              = p.Qsnow.melt_Rn * info.tem.helpers.arrays.onespixtix;
tmp_Rn 				      = max(f.Rn(idx) .* tmp_mr(idx), 0);

fe.Qsnow.potMelt 		= zeros(size(f.Tair));
fe.Qsnow.potMelt(idx)	= tmp_T + tmp_Rn;

end
