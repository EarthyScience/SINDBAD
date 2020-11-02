function [f,fe,fx,s,d,p] = wRootUptake_proportion(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the rootUptake from each of the soil layer proportional to the root fraction
%
% Inputs:
%	- fx.tranAct: actual transpiration
%	- s.wd.pawAct: plant available water (pix,zix)
%   - s.w.wSoil: soil moisture
%
% Outputs:
%   - s.wd.wRootUptake: moisture uptake from each soil layer (nPix,nZix of wSoil) 
%
% Modifies:
% 	- s.w.wSoil
%
% References:
%   -
%
% Notes:
%   - assumes that the uptake from each layer remains proportional to the root fraction
%
% Created by:
%   - Tina Trautmann (ttraut)
%
% Versions:
%   - 1.0 on 13.03.2020 (ttraut): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
%--> get the transpiration
transp          = fx.tranAct(:,tix);
pawActTotal     = sum(s.wd.pawAct,2);
%--> extract from top to bottom and update moisture
for sl  =   1:size(s.w.wSoil,2)
    wSoilAvailProp          =   max(0, s.wd.pawAct(:,sl)./pawActTotal); %necessary because supply can be 0 -> 0./0=NaN
    contrib                 =   transp .* wSoilAvailProp;
    s.w.wSoil(:,sl)         =   s.w.wSoil(:,sl) - contrib;
    s.wd.wRootUptake(:,sl)  =   contrib;
end

end