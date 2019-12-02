function [f,fe,fx,s,d,p] = prec_pVeg_PFT(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets a uniform PFT class
%
% Inputs:
%    - info structure
%
% Outputs:
%   - 
%
% Modifies:
%     - p.pVeg.PFT:  from size(1,1) to size(pix,1)
%
% References:
%    - 
%
% Created by:
%   - unknown (xxx)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

p.pVeg.PFT = p.pVeg.PFT .* info.tem.helpers.arrays.onespix;

end