function [f,fe,fx,s,d,p]    =   prec_gppDem_none(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the scalar for demand GPP to ones and demand GPP to zeros
%
% Inputs:
%   - info
%
% Outputs:
%   - d.gppDem.AllDemScGPP: effective scalar of demands
%   - d.gppDem.gppE: demand-driven GPP
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
%--> set scalar to a constant one (no effect on potential GPP)
d.gppDem.AllDemScGPP        =   info.tem.helpers.arrays.onespixtix;
%--> set GPP demand to zeros
d.gppDem.gppE               =   info.tem.helpers.arrays.zerospixtix;
end