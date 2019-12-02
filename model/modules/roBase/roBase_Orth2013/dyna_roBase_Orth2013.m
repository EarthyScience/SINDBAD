function [f,fe,fx,s,d,p] = dyna_roBase_Orth2013(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the base runoff
%
% Inputs:
%   -   fe.roBase.Rdelay : delay function of roInt as defined by qt parameter
%   
% Outputs:
%   -   fx.roBase : runoff from land [mm/time]
%
% Modifies:
%
% References:
%   -   Orth, R., Koster, R. D., & Seneviratne, S. I. (2013). 
%       Inferring soil moisture memory from streamflow observations using a simple water balance model. Journal of Hydrometeorology, 14(6), 1773-1790.
%
% Notes:
%	- how to handle 60days?!?!
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
    tmin = maxsb(tix-60,1);
    fx.roBase(:,tix) = sum(fx.roOverland(:,tmin:tix) .* fe.roBase.Rdelay,2);        
else % or accumulate land runoff in GW
    fx.roBase(:,tix) = 0;
end

% update the GW pool
s.w.wGW = s.w.wGW + fx.roOverland(:,tix) - fx.roBase(:,tix);

% % roBase for water balance check
% fx.roBase(:,tix) = fx.roTotal(:,tix) - fx.roInt(:,tix);

end
