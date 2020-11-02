function [f,fe,fx,s,d,p] = wSoilRec_wFC(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% computes the downward flow of moisture (drainage) in soil layers based on overflow
% from the upper layers
%
% Inputs:
%	- s.w.wSoil: soil moisture in different layers
%   - s.wd.WBP amount of water that can potentially drain
%   - s.wd.p_wSoilBase_wFC: field capacity of soil in mm
%
% Outputs:
%   - s.wd.wSoilFlow: drainage flux between soil layers (same as nZix, from percolation
%                  into layer 1 and the drainage to the last layer)
%        - drainage from the last layer is saved as groundwater recharge (gwRec)
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
%   - Martin Jung (mjung)
%
% Versions:
%   - 1.0 on 18.11.2019 (skoirala): clean up and consistency
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
%--> get the number of soil layers
nSoilLayers                 =   s.wd.p_wSoilBase_nsoilLayers;
s.wd.wSoilFlow(:,1)         =   fx.wSoilPerc(:,tix);
for sl=1:nSoilLayers-1
    %--> drain excess moisture in oversaturation
    maxDrain                =   max(s.w.wSoil(:,sl) - s.wd.p_wSoilBase_wFC(:,sl), 0);
    %--> store the drainage flux
    s.wd.wSoilFlow(:,sl+1)  =   maxDrain;
    %--> update storages
    s.w.wSoil(:,sl)         =   s.w.wSoil(:,sl) - maxDrain;
    s.w.wSoil(:,sl+1)       =   s.w.wSoil(:,sl+1) + maxDrain;
end
end