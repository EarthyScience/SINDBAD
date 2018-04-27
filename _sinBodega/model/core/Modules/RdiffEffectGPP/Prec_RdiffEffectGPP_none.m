function [fe,fx,d,p] = Prec_RdiffEffectGPP_none(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES:
% 
% CONTACT	: mjung, ncarval
% 
% INPUT
% 
% OUTPUT
% rueGPP    : maximum instantaneous radiation use efficiency [gC/MJ]
%           (d.RdiffEffectGPP.rueGPP)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

% just put here a single maximum radiation use efficiency
d.RdiffEffectGPP.rueGPP = p.RdiffEffectGPP.rue * ones(1,info.forcing.size(2));

end