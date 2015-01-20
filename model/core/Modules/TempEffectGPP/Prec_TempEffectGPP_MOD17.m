function [fe,fx,d,p] = Prec_TempEffectGPP_MOD17(f,fe,fx,s,d,p,info)
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
%           (p.TempEffectGPP.Tmin)
% Tmax      : temperature above which GPP is maximum [ºC]
%           (p.TempEffectGPP.Tmax)
% 
% OUTPUT
% TempScGPP : temperature effect on GPP [] dimensionless, between 0-1
%           (d.TempEffectGPP.TempScGPP)
% 
% DEPENDENCIES  :
% 
% NOTES: Tmin < Tmax ALWAYS!!! can go in the consistency checks!
% 
% #########################################################################

tmp     = ones(1,info.forcing.size(2));
td      = (p.TempEffectGPP.Tmax - p.TempEffectGPP.Tmin) * tmp;
tmax    = p.TempEffectGPP.Tmax * tmp;

tsc                         = f.TairDay ./ td + 1 - tmax ./ td;
tsc(tsc<0)                  = 0;
tsc(tsc>1)                  = 1;
d.TempEffectGPP.TempScGPP   = tsc;

end