function [f,fe,fx,s,d,p] = wRootUptake_TopBottom(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the rootUptake from each of the soil layer from top to bottom
%
% Inputs:
%	- fx.tranAct: actual transpiration
%	- s.wd.p_rootFrac_fracRoot2SoilD: max fraction of moisture that can be uptake from a layer (out of rootFrac module)
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
    wSoilAvail              =   s.wd.awcAct(:,sl);
    contrib                 =   minsb(transp,wSoilAvail);
    s.w.wSoil(:,sl)         =   s.w.wSoil(:,sl) - contrib;
    s.wd.wRootUptake(:,sl)  =   contrib;
    transp                  =   transp-contrib;    
end
end