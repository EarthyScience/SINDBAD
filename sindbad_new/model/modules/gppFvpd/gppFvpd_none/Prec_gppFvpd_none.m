function [fe,fx,d,p] = prec_gppFvpd_none(f,fe,fx,s,d,p,info)
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
%           (d.gppFvpd.VPDScGPP)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

% no effect = 1
d.gppFvpd.VPDScGPP = ones(info.forcing.size);

end