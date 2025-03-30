function [f,fe,fx,s,d,p] = prec_roSat_BergstroemLinVegFrPFT(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates land surface runoff and infiltration to different soil layers
% using 
%
% Inputs:
%   - f.PFT              : PFT classes
%   - p.roSat.berg_scale_PFT0  : berg scalar of PFT class 0
%   - p.roSat.berg_scale_PFT1  : berg scalar of PFT class 1
%   - p.roSat.berg_scale_PFT2  : berg scalar of PFT class 2
%   - p.roSat.berg_scale_PFT3  : berg scalar of PFT class 3
%   - p.roSat.berg_scale_PFT4  : berg scalar of PFT class 4
%   - p.roSat.berg_scale_PFT5  : berg scalar of PFT class 5
%   - p.roSat.berg_scale_PFT6  : berg scalar of PFT class 6
%   - p.roSat.berg_scale_PFT7  : berg scalar of PFT class 7
%   - p.roSat.berg_scale_PFT8  : berg scalar of PFT class 8
%   - p.roSat.berg_scale_PFT9  : berg scalar of PFT class 9
%   - p.roSat.berg_scale_PFT10  : berg scalar of PFT class 10
%   - p.roSat.berg_scale_PFT11  : berg scalar of PFT class 11
%
% Outputs:
%	- s.wd.p_roSat_berg_scale : scalar for s.cd.vegFrac to define shape parameter of runoff-infiltration curve []
%
% Modifies:
%
% References:
%   - Bergström, S. (1992). The HBV model–its structure and applications. SMHI.
%
% Created by:
%   - Tina Trautmann (ttraut)
%
% Versions:
%   - 1.0 on 10.09.2021 (ttraut): based on roSat_BergstroemLinVegFr
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
%--> get the PFT data & assign parameters
tmp_classes = unique(f.PFT);
s.wd.p_roSat_berg_scale =  info.tem.helpers.arrays.onespix;
for nC=1:length(tmp_classes)
    nPFT = tmp_classes(nC);
    s.wd.p_roSat_berg_scale(f.PFT==nPFT,1) = eval(char(['p.roSat.berg_scale_PFT' num2str(nPFT)]));    
end


end
