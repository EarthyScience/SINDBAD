function [fe,fx,d,p] = prec_gppFtemp_MOD17(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: estimate temperature effect on GPP - MOD17 model
% 
% REFERENCES:  MOD17 User’s Guide, Running et al. (2004), Zhao et al.
% (2005)
% 
% CONTACT	: mjung, ncarval
% 
% INPUT
% TairDay   : daytime temperature [ºC]
%           (f.TairDay)
% Tmin      : temperature below which GPP is zero [ºC]
%           (p.gppFtemp.Tmin)
% Tmax      : temperature above which GPP is maximum [ºC]
%           (p.gppFtemp.Tmax)
% 
% OUTPUT
% TempScGPP : temperature effect on GPP [] dimensionless, between 0-1
%           (d.gppFtemp.TempScGPP)
% 
% DEPENDENCIES  :
% 
% NOTES: Tmin < Tmax ALWAYS!!! can go in the consistency checks!
% 
% #########################################################################

tmp     = ones(1,info.forcing.size(2));
td      = (p.gppFtemp.Tmax - p.gppFtemp.Tmin) * tmp;
tmax    = p.gppFtemp.Tmax * tmp;

tsc                         = f.TairDay ./ td + 1 - tmax ./ td;
tsc(tsc<0)                  = 0;
tsc(tsc>1)                  = 1;
d.gppFtemp.TempScGPP   = tsc;

end