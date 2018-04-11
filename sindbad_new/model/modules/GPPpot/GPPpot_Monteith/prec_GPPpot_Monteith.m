function [fe,fx,d,p] = prec_GPPpot_Monteith(f,fe,fx,s,d,p,info)
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
%           (d.GPPpot.rueGPP)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

% just put here a single maximum radiation use efficiency
d.GPPpot.rueGPP = p.GPPpot.rue * ones(1,info.forcing.size(2));

end