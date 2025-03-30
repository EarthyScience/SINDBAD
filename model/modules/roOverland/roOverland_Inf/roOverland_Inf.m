function [f,fe,fx,s,d,p] = roOverland_Inf(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates total overland runoff that passes to the surface storage
%
% Inputs:
%   - fx.roInf: infiltration excess runoff
%
% Outputs:
%   - fx.roOverland : runoff over land [mm/time]
%
% Modifies:
%
% References:
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 18.11.2019 (skoirala)
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
fx.roOverland(:,tix)         = fx.roInf(:,tix);
end
