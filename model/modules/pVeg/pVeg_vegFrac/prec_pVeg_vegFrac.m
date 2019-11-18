function [f,fe,fx,s,d,p] = prec_pVeg_vegFrac(f,fe,fx,s,d,p,info)
% #########################################################################
% all calculations are done in prec
%
% Inputs:
%	- info structure
%
% Outputs:
%   - 
%
% Modifies:
% 	- p.pVeg.vegFr: from size(1,1) to size(pix,1)
%
% References:
%	- 
%
% Created by:
%   - Tina Trautmann (ttraut@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%%
% #########################################################################

p.pVeg.vegFr = p.pVeg.vegFr .* info.tem.helpers.arrays.onespix;

end
