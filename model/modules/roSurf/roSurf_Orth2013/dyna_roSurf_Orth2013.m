function [f,fe,fx,s,d,p] = dyna_roSurf_Orth2013(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the base runoff
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
%   -   1.0 on 18.11.2019 (ttraut)
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% calculate Q from delay of previous days
if tix>60
    tmin = max(tix-60,1);
    fx.roSurf(:,tix) = sum(fx.roOverland(:,tmin:tix) .* fe.roSurf.Rdelay,2);        
else % or accumulate land runoff in surface storage
    fx.roSurf(:,tix) = 0;
end

% update the water pool
s.w.wSurf = s.w.wSurf + fx.roOverland(:,tix) - fx.roSurf(:,tix);

end
