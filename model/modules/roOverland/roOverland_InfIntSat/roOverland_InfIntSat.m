function [f,fe,fx,s,d,p] = roOverland_InfIntSat(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates total overland runoff that passes to the surface storage
%
% Inputs:
%	- fx.roInf: infiltration excess runoff
%	- fx.roInt: intermittent flow
%	- fx.roSat: saturation excess runoff
%
% Outputs:
%   - fx.roOverland : runoff from land [mm/time]
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
fx.roOverland(:,tix)         =   fx.roInf(:,tix) + fx.roInt(:,tix) + fx.roSat(:,tix);
end
