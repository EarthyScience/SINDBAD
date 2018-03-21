function [fe,fx,d,p] = prec_gppFtemp_TEM(f,fe,fx,s,d,p,info)
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
%           (p.gppFtemp.Tmin)
% Tmax      : temperature above which GPP is zero [ºC]
%           (p.gppFtemp.Tmax)
% Topt      : optimum temperature for GPP [ºC]
% 
% OUTPUT
% TempScGPP : temperature effect on GPP [] dimensionless, between 0-1
%           (d.gppFtemp.TempScGPP)
% 
% DEPENDENCIES  :
% 
% NOTES: Tmin < Topt < Tmax ALWAYS!!! can go in the consistency checks!
% 
% #########################################################################

tmp     = ones(1,info.forcing.size(2));
pTmin   = f.TairDay - (p.gppFtemp.Tmin * tmp);
pTmax   = f.TairDay - (p.gppFtemp.Tmax * tmp);
pTopt   = p.gppFtemp.Topt * tmp;
pTScGPP = pTmin .* pTmax ./ ((pTmin .* pTmax) - (f.TairDay - pTopt) .^ 2);

d.gppFtemp.TempScGPP(f.TairDay>p.gppFtemp.Tmax)   = 0;
d.gppFtemp.TempScGPP(f.TairDay<p.gppFtemp.Tmin)   = 0;
d.gppFtemp.TempScGPP                                   = min(max(pTScGPP,0),1);

end