function [f,fe,fx,s,d,p] = prec_gppfRdir_none(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% set the light saturation scalar (light effect) on gppPot to ones
%
% Inputs:
%   - info
%
% Outputs:
%   - d.gppfRdir.LightScGPP: effect of light saturation on potential GPP
%
% Modifies:
%   - 
%
% References:
%   - 
% 
% Created by:
%   - Martin Jung (mjung)
%   - Nuno Carvalhais (ncarval)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): documentation and clean up (changed the output to nPix, nTix)
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
d.gppfRdir.LightScGPP = info.tem.helpers.arrays.onespixtix;
end