function [f,fe,fx,s,d,p] = prec_gppfVPD_none(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% PURPOSE    : 
% 
% REFERENCES:
% 
% CONTACT    : mjung, ncarval
% 
% INPUT
% 
% OUTPU
% VPDScGPP  : effect of VPD on GPP [] dimensionless between 0 - 1
%           (d.gppfVPD.VPDScGPP)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% no effect = 1
d.gppfVPD.VPDScGPP = info.tem.helpers.arrays.onespixtix;

end