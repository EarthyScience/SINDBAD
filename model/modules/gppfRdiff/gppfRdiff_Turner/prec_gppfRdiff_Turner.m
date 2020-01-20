function [f,fe,fx,s,d,p] = prec_gppfRdiff_Turner(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% PURPOSE    : diffuse radiation effect on GPP
% 
% REFERENCES: Turner et al 2006, DOI: 10.1111/j.1600-0889.2006.00221.x
% 
% CONTACT    : mjung, ncarval
% 
% INPUT
% Rg        : global incoming radiation [MJ/m2/time]
%           (f.Rg)
% 
% RgPot     : potential global incoming radiation [MJ/m2/time]
%           (f.RgPot)
% 
% rueRatio  : ratio of clear sky LUE to max LUE, in turner et al., appendix A, e_{g_cs} / e_{g_max}, should be between 0 and 1
% 
% OUTPUT
% CloudScGPP: effect of cloudiness on instantaneous light use efficiency
%           (d.gppfRdiff.CloudScGPP)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

rueRatio                        =   p.gppfRdiff.rueRatio .* info.tem.helpers.arrays.onespixtix;
CI                              =   info.tem.helpers.arrays.zerospixtix;
valid                           =   f.RgPot > 0;
CI(valid)                       =   f.Rg(valid) ./ f.RgPot(valid);
SCI                             =   (CI - minsb(CI)) ./ (maxsb(CI) - minsb(CI));
d.gppfRdiff.CloudScGPP          =   (1 - rueRatio) .* SCI + rueRatio;
end