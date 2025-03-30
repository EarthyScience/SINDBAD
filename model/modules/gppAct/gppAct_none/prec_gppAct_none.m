function [f,fe,fx,s,d,p] = prec_gppAct_none(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the actual GPP to zeros
%
% Inputs:
%   - info
%
% Outputs:
%   - fx.gpp: actual GPP [gC/m2/time]
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
%   - 1.0 on 22.11.2019 (skoirala): documentation and clean up (changed the output to nPix, nTix)
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
fx.gpp = info.tem.helpers.arrays.zerospixtix;
end