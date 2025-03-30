function [f,fe,fx,s,d,p] = prec_gppfwSoil_none(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% set the soil moisture stress on gppPot to ones (no stress)
%
% Inputs:
%   - info
%
% Outputs:
%   - d.gppfwSoil.SMScGPP: soil moisture effect on GPP [] dimensionless, between 0-1
%
% Modifies:
%   - 
%
% References:
%   - 
% 
% Created by:
%   - Nuno Carvalhais (ncarval)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): documentation and clean up 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
%--> set scalar to a constant one (no effect on potential GPP)
d.gppfwSoil.SMScGPP     =   info.tem.helpers.arrays.onespixtix;
end