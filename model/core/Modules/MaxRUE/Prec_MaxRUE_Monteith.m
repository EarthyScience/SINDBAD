function [fe,fx,d,p] = Prec_MaxRUE_Monteith(f,fe,fx,s,d,p,info)
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
%           (d.MaxRUE.rueGPP)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

% just put here a single maximum radiation use efficiency
d.MaxRUE.rueGPP = p.MaxRUE.rue * ones(1,info.forcing.size(2));

end