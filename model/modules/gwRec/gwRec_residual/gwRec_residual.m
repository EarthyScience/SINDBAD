function [f,fe,fx,s,d,p] = gwRec_residual(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates GW recharge as residual of all unused moisture
%
% Inputs: 
%   - s.wd.WBP: residual water
%
% Outputs:
%   - fx.gwRec 
%
% Modifies:
%   - s.w.wGW
%
% Notes:
% simply assume that all remaining (after having subtracted interception
% evap, infiltration excess runoff, saturation runoff, interflow, soil
% moisture recharge from (rainfall+snowmelt)) water goes to GW  
%
% References:
%   - 
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 11.11.2019 (skoirala): clean up
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
fx.gwRec(:,tix) = s.wd.WBP;
s.w.wGW = s.w.wGW + fx.gwRec(:,tix);
end