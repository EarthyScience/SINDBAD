function [f,fe,fx,s,d,p] = prec_gppfVPD_PRELES(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% please adjust ;)
% calculate the VPD stress on gppPot based on Maekelae2008 (eqn 5)
%
% Inputs:
%   - f.VPDDay: daytime vapor pressure deficit [kPa]
%   - p.gppfVPD.k: parameter of the exponential decay function of GPP with VPD
%           [kPa-1] dimensionless [0.06 0.7]; median ~0.4 
%   
% Outputs:
%   - d.gppfVPD.VPDScGPP: VPD effect on GPP [] dimensionless, between 0-1
%
% Modifies:
%   - 
%
% References:
%    - Mäkelä, A., Pulkkinen, M., Kolari, P., et al. (2008). 
%       Developing an empirical model of stand GPP with the LUE approach: 
%       analysis of eddy covariance data at five contrasting conifer sites in Europe. 
%       Global change biology, 14(1), 92-108. 
%
% Notes: 
%   - 
%
% Created by:
%   - Nuno Carvalhais (ncarval)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): documentation and clean up 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% from SHanning's codes
fVPD_VPD            = exp(p.gppfVPD.kappa .* f.VPDDay .* (s.cd.ambCO2./p.gppfVPD.Ca0) .^ p.gppfVPD.Ckappa);
fCO2_CO2            = 1 + (s.cd.ambCO2-p.gppfVPD.Ca0)./(s.cd.ambCO2-p.gppfVPD.Ca0+p.gppfVPD.Cm);
VPDScGPP            = maxsb(0,minsb(1,fVPD_VPD.*fCO2_CO2));
d.gppfVPD.VPDScGPP	= VPDScGPP;

    
end