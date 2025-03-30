function [f,fe,fx,s,d,p] = roSurf_indirect(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the runoff from surface water storage
%
% Inputs:
%	- fx.roOverland 
%   - s.wd.wSurf
% Outputs:
%   - fx.roSurf and its indirect/slow component
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
%--> fraction of overland runoff that recharges the surface water and the
%fraction that flows out directly
fx.wSurfRec(:,tix)      =   fx.roOverland(:,tix);

%--> fraction of surface storage that flows out as surface runoff 
fx.roSurf(:,tix)         =   p.roSurf.dc .* s.w.wSurf;

%--> update surface water storage
s.w.wSurf               =   s.w.wSurf + fx.wSurfRec(:,tix) - fx.roSurf(:,tix);


end
