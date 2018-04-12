function [fe,fx,d,p,f] = prec_GPPfRdiff_none(f,fe,fx,s,d,p,info)
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
%           (d.GPPfRdiff.rueGPP)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

% just put here a single maximum radiation use efficiency
d.GPPfRdiff.rueGPP = p.GPPfRdiff.rue * ones(1,info.forcing.size(2));

end