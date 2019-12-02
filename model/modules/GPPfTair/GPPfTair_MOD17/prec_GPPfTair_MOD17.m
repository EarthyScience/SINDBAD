function [f,fe,fx,s,d,p] = prec_GPPfTair_MOD17(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% PURPOSE    : estimate temperature effect on GPP - MOD17 model
% 
% REFERENCES:  MOD17 User?s Guide, Running et al. (2004), Zhao et al.
% (2005)
% 
% CONTACT    : mjung, ncarval
% 
% INPUT
% TairDay   : daytime temperature [?C]
%           (f.TairDay)
% Tmin      : temperature below which GPP is zero [?C]
%           (p.GPPfTair.Tmin)
% Tmax      : temperature above which GPP is maximum [?C]
%           (p.GPPfTair.Tmax)
% 
% OUTPUT
% TempScGPP : temperature effect on GPP [] dimensionless, between 0-1
%           (d.GPPfTair.TempScGPP)
% 
% DEPENDENCIES  :
% 
% NOTES: Tmin < Tmax ALWAYS!!! can go in the consistency checks!
% 
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

tmp                         =   info.tem.helpers.arrays.onestix;
td                          =   (p.GPPfTair.Tmax - p.GPPfTair.Tmin) * tmp;
tmax                        =   p.GPPfTair.Tmax * tmp;
tsc                         =   f.TairDay ./ td + 1 - tmax ./ td;
tsc(tsc<0)                  =   0;
tsc(tsc>1)                  =   1;
d.GPPfTair.TempScGPP        =   tsc;

end