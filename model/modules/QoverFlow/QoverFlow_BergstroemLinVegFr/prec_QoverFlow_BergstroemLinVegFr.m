function [f,fe,fx,s,d,p] = prec_QoverFlow_BergstroemLinVegFr(f,fe,fx,s,d,p,info)
% #########################################################################
% calculates land surface runoff and infiltration to different soil layers
%
% Inputs:
%	- p.QoverFlow.berg_scale : scaling parameter to define p.berg from p.vegFr
%   - p.pVeg.vegFr:            vegetation (cover) fraction (npix,ntix)
%
% Outputs:
%   - p.QoverFlow.berg : shape parameter runoff-infiltration curve (Bergstroem)
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
p.QoverFlow.berg = max(0.1, p.QoverFlow.berg_scale .* p.pVeg.vegFr); 

end
