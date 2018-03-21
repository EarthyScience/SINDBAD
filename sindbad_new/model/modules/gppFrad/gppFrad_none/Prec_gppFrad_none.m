function [fe,fx,d,p] = prec_gppFrad_none(f,fe,fx,s,d,p,info)
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
%           (d.gppFrad.LightScGPP)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

% no effect (needs to be 1!)
d.gppFrad.LightScGPP = ones(info.forcing.size);

end