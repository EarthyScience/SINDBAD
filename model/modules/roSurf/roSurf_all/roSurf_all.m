function [f,fe,fx,s,d,p] = roSurf_all(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the runoff from surface water storage
%
% Inputs:
%	- fx.roOverland 
%   - s.wd.wSurf
%
% Outputs:
%   - fx.roSurf 
%
% Modifies:
% 	- s.w.wSurf
%
% References:
%	- 
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 20.11.2019 (skoirala): combine roSurfDir,Indir, wSurfRec
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
%--> all overland flow becomes surface runoff
fx.roSurf(:,tix)      =   fx.roOverland(:,tix);


end
