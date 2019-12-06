function [f,fe,fx,s,d,p] = prec_gppfTair_TEM(f,fe,fx,s,d,p,info)
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
%           (p.gppfTair.Tmin)
% Tmax      : temperature above which GPP is zero [?C]
%           (p.gppfTair.Tmax)
% Topt      : optimum temperature for GPP [?C]
% 
% OUTPUT
% TempScGPP : temperature effect on GPP [] dimensionless, between 0-1
%           (d.gppfTair.TempScGPP)
% 
% DEPENDENCIES  :
% 
% NOTES: Tmin < Topt < Tmax ALWAYS!!! can go in the consistency checks!
% 
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

tmp             =   info.tem.helpers.arrays.onestix;

pTmin           =   f.TairDay - (p.gppfTair.Tmin * tmp);
pTmax           =   f.TairDay - (p.gppfTair.Tmax * tmp);
pTopt           =   p.gppfTair.Topt * tmp;
pTScGPP         =   pTmin .* pTmax ./ ((pTmin .* pTmax) - (f.TairDay - pTopt) .^ 2);

d.gppfTair.TempScGPP(f.TairDay>p.gppfTair.Tmax)   =     0;
d.gppfTair.TempScGPP(f.TairDay<p.gppfTair.Tmin)   =     0;
d.gppfTair.TempScGPP                              =     minsb(maxsb(pTScGPP,0),1);

end