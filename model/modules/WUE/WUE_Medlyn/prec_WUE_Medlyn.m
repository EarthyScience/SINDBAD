function [f,fe,fx,s,d,p] = prec_WUE_Medlyn(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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
%           (p.WUE.g1)
% ca        : ambient CO2 concentration [ppm]
%           (f.ca)
%
% 
% OUTPUT
% AoE       : water use efficiency - ratio of assimilation and
%           transpiration fluxes [gC/mmH2O]
%           (d.WUE.AoE)
% ci        : internal CO2 concentration [ppm]
%           (d.WUE.ci)
% 
% DEPENDENCIES  :
% 
% NOTES: check the 6.6667e-004 conversion factor!
% 
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

VPDDay                      =   f.VPDDay;
VPDDay(f.VPDDay < 1E-4)     =   1E-4;
pg1                         =   p.WUE.g1 .* info.tem.helpers.arrays.onestix;
fe.WUE.AoENoCO2             =   6.6667e-004 .* f.PsurfDay ./ (1.6 .* (VPDDay + pg1 .* sqrt(VPDDay)));
fe.WUE.ciNoCO2              =   pg1 ./ (pg1 + sqrt(VPDDay));
% d.WUE.AoE                   =   6.6667e-004 .* f.ca .* f.PsurfDay ./ (1.6 .* (VPDDay + pg1 .* sqrt(VPDDay)));
% Compute ci according to Medlyn et al 2012
% d.WUE.ci	= f.ca .* pg1 ./ (pg1 + sqrt(VPDDay));


end