function [f,fe,fx,s,d,p] = prec_roSat_BergstroemLinVegFr(f,fe,fx,s,d,p,info)
% #########################################################################
% calculates land surface runoff and infiltration to different soil layers
%
% Inputs:
%	- p.roSat.berg_scale : scaling parameter to define p.berg from p.vegFr
%   - s.cd.vegFrac:            vegetation (cover) fraction (npix,ntix)
%
% Outputs:
%   - p.roSat.berg : shape parameter runoff-infiltration curve (Bergstroem)
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
p.roSat.berg = max(0.1, p.roSat.berg_scale .* s.cd.vegFrac); 

end
