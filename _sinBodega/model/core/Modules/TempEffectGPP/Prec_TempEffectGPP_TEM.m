function [fe,fx,d,p] = Prec_TempEffectGPP_TEM(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: estimate temperature effect on GPP
% 
% REFERENCES: ???
% 
% CONTACT	: mjung, ncarval
% 
% INPUT
% TairDay   : daytime temperature [ºC]
%           (f.TairDay)
% Tmin      : temperature below which GPP is zero [ºC]
%           (p.TempEffectGPP.Tmin)
% Tmax      : temperature above which GPP is zero [ºC]
%           (p.TempEffectGPP.Tmax)
% Topt      : optimum temperature for GPP [ºC]
% 
% OUTPUT
% TempScGPP : temperature effect on GPP [] dimensionless, between 0-1
%           (d.TempEffectGPP.TempScGPP)
% 
% DEPENDENCIES  :
% 
% NOTES: Tmin < Topt < Tmax ALWAYS!!! can go in the consistency checks!
% 
% #########################################################################

tmp     = ones(1,info.forcing.size(2));
pTmin   = f.TairDay - (p.TempEffectGPP.Tmin * tmp);
pTmax   = f.TairDay - (p.TempEffectGPP.Tmax * tmp);
pTopt   = p.TempEffectGPP.Topt * tmp;
pTScGPP = pTmin .* pTmax ./ ((pTmin .* pTmax) - (f.TairDay - pTopt) .^ 2);

d.TempEffectGPP.TempScGPP(f.TairDay>p.TempEffectGPP.Tmax)   = 0;
d.TempEffectGPP.TempScGPP(f.TairDay<p.TempEffectGPP.Tmin)   = 0;
d.TempEffectGPP.TempScGPP                                   = min(max(pTScGPP,0),1);

end