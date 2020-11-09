function [f,fe,fx,s,d,p] = dyna_gppfVPD_PRELES(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% please adjust ;)
% calculate the VPD stress on gppPot based on Maekelae2008 and PRELES model
%
% Inputs:
%   - f.VPDDay: daytime vapor pressure deficit [kPa]
%   - p.gppfVPD.kappa: parameter of the exponential decay function of GPP with
%       VPD [kPa-1] dimensionless [0.06 0.7]; median ~0.4, same as k from
%       Maekaelae 2008
%   - p.gppfVPD.cKappa: parameter modulating co2 effect on VPD response to GPP
%   - p.gppfVPD.Ca0: base co2 concentration
%   - p.gppfVPD.Cam: parameter modulation mean co2 effect on GPP
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
%       analysis of eddy covariance data at five contrasting conifer sites in
%       Europe. Global change biology, 14(1), 92-108.
%    - http://www.metla.fi/julkaisut/workingpapers/2012/mwp247.pdf
%
% Notes:
%   - sign of exponent is changed to have kappa parameter as positive values
%
% Created by:
%   - Nuno Carvalhais (ncarval)
%
% Versions:
%   - 1.1 on 22.11.2020 (skoirala): changing units to kpa for vpd and sign of
%     kappa to match with Maekaelae2008
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% from SHanning's codes
fVPD_VPD                    = exp(p.gppfVPD.kappa .* -f.VPDDay(:,tix) .* (s.cd.ambCO2 ./ p.gppfVPD.Ca0) .^ p.gppfVPD.Ckappa);
fCO2_CO2                    = 1 + (s.cd.ambCO2 - p.gppfVPD.Ca0) ./ (s.cd.ambCO2 - p.gppfVPD.Ca0 + p.gppfVPD.Cm);
VPDScGPP                    = max(0, min(1, fVPD_VPD .* fCO2_CO2));
d.gppfVPD.VPDScGPP(:,tix)	= VPDScGPP;

end