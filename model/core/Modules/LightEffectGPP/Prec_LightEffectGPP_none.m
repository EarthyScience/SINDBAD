function [fe,fx,d,p] = Prec_LightEffectGPP_none(f,fe,fx,s,d,p,info)
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
%           (d.LightEffectGPP.LightScGPP)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

% no effect (needs to be 1!)
d.LightEffectGPP.LightScGPP = ones(info.forcing.size);

end