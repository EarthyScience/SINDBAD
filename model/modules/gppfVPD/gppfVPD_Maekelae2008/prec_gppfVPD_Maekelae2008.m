function [f,fe,fx,s,d,p] = prec_gppfVPD_Maekelae2008(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% PURPOSE    : compute the VPD effect on GPP according to Maekelae et al
% 2008.
% 
% REFERENCES: Maekelae et al 2008 - Developing an empirical model of stand
% GPP with the LUE approach: analysis of eddy covariance data at five
% contrasting conifer sites in Europen
% 
% CONTACT    : mjung, ncarval
% 
% INPUT
% VPDDay    : daytime vapor pressure deficit [kPa]
%           (f.VPDDay)
% k         : parameter of the exponential decay function of GPP with VPD
%           [] dimensionless [-0.06 -0.7]; median ~-0.4 
%           (p.gppfVPD.k)
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

pk                      =   p.gppfVPD.k * info.tem.helpers.arrays.onestix;
VPDScGPP                =   exp(pk .* f.VPDDay);
VPDScGPP(VPDScGPP>1)    =   1;
d.gppfVPD.VPDScGPP      =   VPDScGPP;
end