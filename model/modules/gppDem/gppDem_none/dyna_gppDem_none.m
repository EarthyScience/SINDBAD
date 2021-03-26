function [f,fe,fx,s,d,p] = dyna_gppDem_none(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the scalar for demand GPP to ones and demand GPP to zeros
%
% Inputs:
%   - info
%
% Outputs:
%   - d.gppDem.gppE: demand-driven GPP with no stress
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
% compute demand GPP with no stress. d.gppDem.AllDemScGPP is set to ones in the prec, and hence the demand have no stress in GPP.
d.gppDem.gppE(:,tix)           =   s.cd.fAPAR .* d.gppPot.gppPot(:,tix) .* d.gppDem.AllDemScGPP(:,tix);
end