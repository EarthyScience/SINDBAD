function [f,fe,fx,s,d,p] = prec_gppfVPD_MOD17(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% PURPOSE    : compute the VPD effect on GPP according to the MOD17 model
% 
% REFERENCES:  MOD17 User?s Guide, Running et al. (2004), Zhao et al.
% (2005)
% 
% CONTACT    : mjung, ncarval
% 
% INPUT
% VPDDay    : daytime vapor pressure deficit [kPa]
%           (f.VPDDay)
% VPDmax    : VPD value above which GPP is 0 [kPa]
%           (p.gppfVPD.VPDmax)
% VPDmin    : VPD value below which GPP is maximum [kPa]
%           (p.gppfVPD.VPDmin)
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

tmp                      =   info.tem.helpers.arrays.onestix;

td                      =   (p.gppfVPD.VPDmax - p.gppfVPD.VPDmin)   * tmp;
pVPDmax                 =   p.gppfVPD.VPDmax                             * tmp;

vsc                     =   -f.VPDDay ./ td + pVPDmax ./ td;

vsc(vsc<0)              =   0;
vsc(vsc>1)              =   1;

d.gppfVPD.VPDScGPP      =   vsc;

end