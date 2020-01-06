function [f,fe,fx,s,d,p] = prec_gppPot_Monteith(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% set the potential GPP as maximum RUE 
%
% Inputs:
%   - p.gppPot.maxrue : maximum instantaneous radiation use efficiency [gC/MJ]
%
% Outputs:
%   - d.gppPot.rueGPP: potential GPP based on RUE (nPix,nTix)
%
% Modifies:
%   - 
%
% References:
%   - 
%
% Notes:
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
%--> set rueGPP to a constant  
d.gppPot.rueGPP = p.gppPot.maxrue * info.tem.helpers.arrays.onespixtix;
end