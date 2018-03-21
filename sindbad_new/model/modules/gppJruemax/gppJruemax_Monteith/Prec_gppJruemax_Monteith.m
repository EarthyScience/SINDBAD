function [fe,fx,d,p] = prec_gppJruemax_Monteith(f,fe,fx,s,d,p,info)
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
%           (d.gppJruemax.rueGPP)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

% just put here a single maximum radiation use efficiency
d.gppJruemax.rueGPP = p.gppJruemax.rue * ones(1,info.forcing.size(2));

end