function [fe,fx,d,p] = prec_gppFtemp_WP(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: estimate temperature effect on GPP
% 
% REFERENCES: Wang et al 2014 - Biophsyical constraints on gross primary
% production by the terrestrial biosphere 
% 
% CONTACT	: mjung, ncarval
% 
% INPUT
% TairDay   : daytime temperature [ºC]
%           (f.TairDay)
% Tmax      : minimum temperature for maximum GPP [ºC]
%           (p.gppFtemp.Tmax)
% 
% OUTPUT
% TempScGPP : temperature effect on GPP [] dimensionless, between 0-1
%           (d.gppFtemp.TempScGPP)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

pTmax   = p.gppFtemp.Tmax * ones(1,info.forcing.size(2));
tsc     = f.TairDay ./ pTmax;

tsc(tsc<0)  = 0;
tsc(tsc>1)  = 1;

d.gppFtemp.TempScGPP = tsc;

end