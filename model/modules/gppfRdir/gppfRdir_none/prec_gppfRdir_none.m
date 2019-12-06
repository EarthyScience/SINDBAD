function [f,fe,fx,s,d,p] = prec_gppfRdir_none(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% PURPOSE    : saturating light function
% 
% REFERENCES:
% 
% CONTACT    : mung, ncarval
% 
% INPUT
% 
% OUTPUT
% LightScGPP: light saturation scalar [] dimensionless
%           (d.gppfRdir.LightScGPP)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% no effect (needs to be 1!)
d.gppfRdir.LightScGPP = info.tem.helpers.arrays.onespixtix;
end