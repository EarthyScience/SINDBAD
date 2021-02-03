function [f,fe,fx,s,d,p] = roSat_Zhang2008(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the saturation excess runoff as a fraction of incoming water
%
% Inputs:
%	- fe.PET.PET: potential ET
%   - s.wd.p_wSoilBase_wAWC: maximum available water in soil per  layer
%   - s.wd.WBP: amount of incoming water
%
% Outputs:
%   - fx.roSat: saturation excess runoff in mm/day
%
% Modifies:
% 	- s.wd.WBP
%
% References:
%	- Zhang et al 2008, Water balance modeling over variable time scales
%   based on the Budyko framework ? Model development and testing, Journal of Hydrology
%   - a combination of eq 14 and eq 15 in zhang et al 2008
% 
% Notes: 
%   - is supposed to work over multiple time scales. it represents the
%   'fast' or 'direct' runoff and thus it's conceptually not really
%   consistent with 'saturation runoff'. it basically lumps saturation runoff
%   and interflow, i.e. if using this approach for saturation runoff it would
%   be consistent to set interflow to none
%   - supply limit is (s.wd.WBP): Zhang et al use precipitation as supply limit. we here use precip +snow
%   melt - interception - infliltration excess runoff (i.e. the water that
%   arrives at the ground) - this is more consistent with the budyko logic
%   than just using precip
% 
% Created by:
%   - Martin Jung (mjung)
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 11.11.2019 (skoirala): cleaned up the code
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
%--> a supply - demand limit concept cf Budyko
%-->  calc demand limit (X0)
X0                  =   fe.PET.PET(:,tix) + sum(s.wd.p_wSoilBase_wSat,2) - sum(s.w.wSoil,2);

%catch for division by zero
roSat               =   info.tem.helpers.arrays.zerospix;
valids              =   s.wd.WBP > 0;
%--> set roSat 
roSat(valids)       =   s.wd.WBP(valids) - s.wd.WBP(valids) .*(1 + X0(valids) ./s.wd.WBP(valids) - ...
                        ( 1 + (X0(valids) ./s.wd.WBP(valids)).^(1./ p.roSat.alpha) ).^ p.roSat.alpha); 
fx.roSat(:,tix)     =   roSat;
%--> adjust the remaining water
s.wd.WBP            =   s.wd.WBP - fx.roSat(:,tix);
end
