function [f,fe,fx,s,d,p] = prec_GPPfTair_TEM(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% PURPOSE    : estimate temperature effect on GPP
% 
% REFERENCES: ???
% 
% CONTACT    : mjung, ncarval
% 
% INPUT
% TairDay   : daytime temperature [?C]
%           (f.TairDay)
% Tmin      : temperature below which GPP is zero [?C]
%           (p.GPPfTair.Tmin)
% Tmax      : temperature above which GPP is zero [?C]
%           (p.GPPfTair.Tmax)
% Topt      : optimum temperature for GPP [?C]
% 
% OUTPUT
% TempScGPP : temperature effect on GPP [] dimensionless, between 0-1
%           (d.GPPfTair.TempScGPP)
% 
% DEPENDENCIES  :
% 
% NOTES: Tmin < Topt < Tmax ALWAYS!!! can go in the consistency checks!
% 
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

tmp             =   info.tem.helpers.arrays.onestix;

pTmin           =   f.TairDay - (p.GPPfTair.Tmin * tmp);
pTmax           =   f.TairDay - (p.GPPfTair.Tmax * tmp);
pTopt           =   p.GPPfTair.Topt * tmp;
pTScGPP         =   pTmin .* pTmax ./ ((pTmin .* pTmax) - (f.TairDay - pTopt) .^ 2);

d.GPPfTair.TempScGPP(f.TairDay>p.GPPfTair.Tmax)   =     0;
d.GPPfTair.TempScGPP(f.TairDay<p.GPPfTair.Tmin)   =     0;
d.GPPfTair.TempScGPP                              =     minsb(maxsb(pTScGPP,0),1);

end