function [f,fe,fx,s,d,p] = prec_GPPfVPD_none(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES:
% 
% CONTACT	: mjung, ncarval
% 
% INPUT
% 
% OUTPU
% VPDScGPP  : effect of VPD on GPP [] dimensionless between 0 - 1
%           (d.GPPfVPD.VPDScGPP)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

% no effect = 1
d.GPPfVPD.VPDScGPP = info.tem.helpers.arrays.onespixtix;

end