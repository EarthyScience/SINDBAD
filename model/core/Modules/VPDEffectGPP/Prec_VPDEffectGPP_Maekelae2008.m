function [fe,fx,d,p] = Prec_VPDEffectGPP_Maekelae2008(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: compute the VPD effect on GPP according to Maekelae et al
% 2008.
% 
% REFERENCES: Maekelae et al 2008 - Developing an empirical model of stand
% GPP with the LUE approach: analysis of eddy covariance data at five
% contrasting conifer sites in Europen
% 
% CONTACT	: mjung, ncarval
% 
% INPUT
% VPDDay    : daytime vapor pressure deficit [kPa]
%           (f.VPDDay)
% k         : parameter of the exponential decay function of GPP with VPD
%           [] dimensionless [-0.06 -0.7]; median ~-0.4 
%           (p.VPDEffectGPP.k)
% 
% OUTPUT
% VPDScGPP  : VPD effect on GPP [] dimensionless, between 0-1
%           (d.VPDEffectGPP.VPDScGPP)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

pk                      = p.VPDEffectGPP.k * ones(1,info.forcing.size(2));
VPDScGPP                = exp(pk .* f.VPDDay);
VPDScGPP(VPDScGPP>1)    = 1;
d.VPDEffectGPP.VPDScGPP = VPDScGPP;
end