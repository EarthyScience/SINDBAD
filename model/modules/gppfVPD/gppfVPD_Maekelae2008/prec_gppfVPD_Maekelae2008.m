function [f,fe,fx,s,d,p] = prec_gppfVPD_Maekelae2008(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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
%   - Equation 5. a negative exponent is introduced to have positive parameter 
%      values
%
% Created by:
%   - Nuno Carvalhais (ncarval)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): documentation and clean up 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
pk                      =   p.gppfVPD.k .* info.tem.helpers.arrays.onestix;
VPDScGPP                =   exp(-pk .* f.VPDDay);
VPDScGPP(VPDScGPP>1)    =   1;
d.gppfVPD.VPDScGPP      =   VPDScGPP;
end