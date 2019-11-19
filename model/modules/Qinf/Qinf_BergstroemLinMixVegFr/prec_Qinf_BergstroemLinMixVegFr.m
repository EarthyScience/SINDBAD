function [f,fe,fx,s,d,p] = prec_Qinf_BergstroemLinMixVegFr(f,fe,fx,s,d,p,info)
% #########################################################################
% calculates land surface runoff and infiltration to different soil layers
%
% Inputs:
%   - p.Qinf.berg_scaleV : scaling parameter to define p.berg from p.vegFr
%                               for vegetated fraction
%   - p.Qinf.berg_scaleS : scaling parameter to define p.berg from p.vegFr
%                               for non vegetated fraction
%   - p.pVeg.vegFr:             vegetation (cover) fraction (npix,ntix)
%
% Outputs:
%   - p.Qinf.berg : shape parameter runoff-infiltration curve (Bergstroem)
%
% Modifies:
% 	- 
%
% References:
%	- Bergstroem 1992
%
% Created by:
%   - Tina Trautmann (ttraut@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%%
% #########################################################################

% get p.berg as linear function of p.berg_scal and p.vegFr
p.Qinf.berg = p.Qinf.berg_scaleV .* p.pVeg.vegFr + p.Qinf.berg_scaleS .* (1-p.pVeg.vegFr);
p.Qinf.berg = max(0.1, p.Qinf.berg); % do this?

end
