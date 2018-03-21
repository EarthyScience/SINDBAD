function [fe,fx,d,p] = prec_wue_Medlyn(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES:
% 
% CONTACT	: mjung, ncarval
% 
% INPUT
% VPDDay    : daytime vapor pressure deficit [kPa]
%           (f.VPDDay)
% g1        : conductance parameter of Medly et al [kPA^0.5] ranging
%           between [0.9 7]; median ~3.5
%           (p.wue.g1)
% ca        : ambient CO2 concentration [ppm]
%           (f.ca)
%
% 
% OUTPUT
% AoE       : water use efficiency - ratio of assimilation and
%           transpiration fluxes [gC/mmH2O]
%           (d.wue.AoE)
% ci        : internal CO2 concentration [ppm]
%           (d.wue.ci)
% 
% DEPENDENCIES  :
% 
% NOTES: check the 6.6667e-004 conversion factor!
% 
% #########################################################################

VPDDay                  = f.VPDDay;
VPDDay(f.VPDDay < 1E-4) = 1E-4;
pg1                     = p.wue.g1 * ones(1,info.forcing.size(2));
d.wue.AoE               = 6.6667e-004 .* f.ca .* f.PsurfDay ./ (1.6 .* (VPDDay + pg1 .* sqrt(VPDDay)));

% Compute ci according to Medlyn et al 2012
d.wue.ci	= f.ca .* pg1 ./ (pg1 + sqrt(VPDDay));


end