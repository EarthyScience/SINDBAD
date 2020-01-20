function [f,fe,fx,s,d,p] = prec_gppfRdiff_none(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% PURPOSE    : 
% 
% REFERENCES:
% 
% CONTACT    : mjung, ncarval
% 
% INPUT
% 
% OUTPUT
% rueGPP    : maximum instantaneous radiation use efficiency [gC/MJ]
%           (d.gppfRdiff.rueGPP)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% just put here a single maximum radiation use efficiency
d.gppfRdiff.CloudScGPP = info.tem.helpers.arrays.onespixtix;

end