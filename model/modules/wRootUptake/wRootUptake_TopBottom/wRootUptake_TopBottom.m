function [f,fe,fx,s,d,p] = wRootUptake_TopBottom(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the rootUptake from each of the soil layer from top to bottom
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
%   - assumes that the uptake is prioritized from top to bottom, irrespective of root fraction of the layers
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 18.11.2019 (skoirala): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
%--> get the transpiration
transp          = fx.tranAct(:,tix);

%--> extract from top to bottom and update moisture
for sl  =   1:size(s.w.wSoil,2)
    wSoilAvail              =   s.wd.pawAct(:,sl);
    contrib                 =   min(transp,wSoilAvail);
    s.w.wSoil(:,sl)         =   s.w.wSoil(:,sl) - contrib;
    s.wd.wRootUptake(:,sl)  =   contrib;
    transp                  =   transp-contrib;    
end

end