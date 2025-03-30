function [f,fe,fx,s,d,p] = tranAct_demSup(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the actual transpiration as the minimum of the supply and demand
%
% Inputs:
%   - d.tranSup.tranSup: supply limited transpiration
%   - d.tranDem.tranDem: climate demand driven transpiration
%
% Outputs:
%   - fx.tranAct: actual transpiration 
%
% Modifies:
%   - 
%
% References:
%   - 
%
% Notes:
%   - ignores biological limitation of  transpiration demand
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
fx.tranAct(:,tix)	= min(d.tranDem.tranDem(:,tix),d.tranSup.tranSup(:,tix));
end