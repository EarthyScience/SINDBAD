function [f,fe,fx,s,d,p] = prec_gppfVPD_Wang2005(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% PURPOSE    : compute  the CO2 compensation point by Wang et al 2014
% 
% REFERENCES: 
% 
% CONTACT    : mjung, ncarval
% 
% INPUT
% VPDDay    : daytime vapor pressure deficit [kPa]
%           (f.VPDDay)
% TairDay   : daytime temperature [�C]
%           (f.TairDay)
% ca        : atmospheric concetration of CO2 [ppm]
%           (f.ca)
% g1        : conductance parameter of Medly et al [kPA^0.5] ranging
%           between [0.9 7]; median ~3.5
%           (p.WUE.g1)
% ci        : internal CO2 concentration [ppm]
%           (d.WUE.ci)
% 
% OUTPUT
% VPDScGPP  : VPD effect on GPP [] dimensionless, between 0-1
%           (d.gppfVPD.VPDScGPP)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% calculate co2 compensation point after Bernacci (C3 photosynthesis) as
% suggested by Wang et al 2014
Tparam          = 0.0512;   % very ecophysiologically based parameters, 
CompPointRef    = 42.75;    % avoid optimize
CO2CompPoint    = CompPointRef .* exp(Tparam .* (f.TairDay - 25));

% 
d.gppfVPD.VPDScGPP = (d.WUE.ci - CO2CompPoint) ./ (d.WUE.ci + 2 .* CO2CompPoint);

end