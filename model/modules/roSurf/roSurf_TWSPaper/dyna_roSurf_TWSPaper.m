function [f,fe,fx,s,d,p] = dyna_roSurf_TWSPaper(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the base runoff
% based on Orth et al. 2013 and as it is used in Trautmannet al. 2018
%
% Inputs:
%   -   fe.roSurf.Rdelay : delay function of roInt as defined by qt parameter
%   
% Outputs:
%   -   fx.roSurf : runoff from land [mm/time]
%
% Modifies:
%
% References:
%   -   Orth, R., Koster, R. D., & Seneviratne, S. I. (2013). 
%       Inferring soil moisture memory from streamflow observations using a simple water balance model. Journal of Hydrometeorology, 14(6), 1773-1790.
%
% Notes:
%	- how to handle 60days?!?!
%   - used in Trautmann et al. 2018
%
% Created by:
%   -   Tina Trautmann (ttraut)
%
% Versions:
%   -   1.1 on 21.01.2020 (ttraut) : calculate wSurf based on water balance
%   (1:1 as in TWS Paper)
%   -   1.0 on 18.11.2019 (ttraut)
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% calculate Q from delay of previous days
if tix>60
    tmin = max(tix-60,1);
    fx.roSurf(:,tix) = sum(fx.roOverland(:,tmin:tix) .* fe.roSurf.Rdelay,2);    
    % calculate wSurf by water balance
    dSurf =(fe.rainSnow.rain(:,tix)+fe.rainSnow.snow(:,tix))-fx.evapSoil(:,tix) - fx.evapSub(:,tix) - fx.roSurf(:,tix) - (sum(s.w.wSnow,2) - sum(s.prev.s_w_wSnow,2)) - (sum(s.w.wSoil,2) - sum(s.prev.s_w_wSoil,2));
    s.w.wSurf = s.w.wSurf + dSurf;
else % or accumulate land runoff in surface storage
    fx.roSurf(:,tix) = 0;
    % update the water pool
    s.w.wSurf = s.w.wSurf + fx.roOverland(:,tix);
end



end
