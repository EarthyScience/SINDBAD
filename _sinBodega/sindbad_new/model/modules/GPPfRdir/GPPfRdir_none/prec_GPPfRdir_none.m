function [f,fe,fx,s,d,p] = prec_GPPfRdir_none(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: saturating light function
% 
% REFERENCES:
% 
% CONTACT	: mung, ncarval
% 
% INPUT
% 
% OUTPUT
% LightScGPP: light saturation scalar [] dimensionless
%           (d.GPPfRdir.LightScGPP)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

% no effect (needs to be 1!)
d.GPPfRdir.LightScGPP = ones(info.forcing.size);

end