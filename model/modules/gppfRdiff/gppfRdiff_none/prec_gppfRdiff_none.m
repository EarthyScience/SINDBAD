function [f,fe,fx,s,d,p] = prec_gppfRdiff_none(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% set the cloudiness scalar (radiation diffusion) for gppPot to ones
%
% Inputs:
%   - info
%
% Outputs:
%   - d.gppfRdiff.CloudScGPP: effect of cloudiness on potential GPP
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
%--> set scalar to a constant one (no effect on potential GPP)
d.gppfRdiff.CloudScGPP = info.tem.helpers.arrays.onespixtix;
end