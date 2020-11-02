function [f,fe,fx,s,d,p] = wSoilPerc_WBP(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% computes the percolation into the soil after the surface runoff and evaporation 
% processes are complete
% 
% Inputs:
%	- s.wd.WBP: water budget pool
%
% Outputs:
%   - fx.wSoilPerc: soil percolation
%
% Modifies:
% 	- s.w.wSoil 
%   - s.wd.WBP
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
%--> get the number of soil layers
nSoilLayers             =   s.wd.p_wSoilBase_nsoilLayers;
%--> set WBP as the soil percolation
fx.wSoilPerc(:,tix)     =   s.wd.WBP;
%--> update the soil moisture in the first layer
s.w.wSoil(:,1)          =   s.w.wSoil(:,1) + fx.wSoilPerc(:,tix);
%--> calculate the oversaturation of the first layer 
wSoilExc                =   max(s.w.wSoil(:,1)-s.wd.p_wSoilBase_wSat(:,1),0);
s.w.wSoil(:,1)          =   s.w.wSoil(:,1) - wSoilExc;
%--> reallocate excess moisture of 1st layer to deeper layers 
for sl  =   1:size(s.w.wSoil,2)
    ip                  =   min(s.wd.p_wSoilBase_wSat(:,sl)  - s.w.wSoil(:,sl), wSoilExc);
    s.w.wSoil(:,sl)     =   s.w.wSoil(:,sl) + ip;
    wSoilExc            =   wSoilExc - ip;
end
s.wd.WBP                =   wSoilExc;

%-->  if the excess moisture is larger than the soil storage capacity, add that amount to GW storage
% s.w.wGW                 =   s.w.wGW + s.wd.WBP;
end
% what should be done if there is still more water?
% if sum(wSoilExc) > 0.001
% disp([pad(' CRIT MODEL RUN',20,'left') ' : ' pad('wSoilPerc_WBP',20) ' | the excess overflow of the percolation does not fit in the soil storage'])
% end
