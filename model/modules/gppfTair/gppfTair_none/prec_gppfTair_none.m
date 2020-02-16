function [f,fe,fx,s,d,p] = prec_gppfTair_none(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% set the temperature stress on gppPot to ones (no stress)
%
% Inputs:
%   - info
%
% Outputs:
%   - d.gppfTair.TempScGPP: effect of temperature on potential GPP
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
d.gppfTair.TempScGPP = info.tem.helpers.arrays.onespixtix;
end