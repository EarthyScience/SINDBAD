function [f,fe,fx,s,d,p] = prec_GPPfRdiff_none(f,fe,fx,s,d,p,info)
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
d.GPPfRdiff.rueGPP = p.GPPfRdiff.rue * info.tem.helpers.arrays.onestix;

end