function [f,fe,fx,s,d,p] = roSurf_directIndirect(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the runoff from surface water storage
%
% Inputs:
%	- fx.roOverland 
%   - s.wd.wSurf
%
% Outputs:
%   - fx.roSurf and its direct and indirect components
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
roOverland               =   fx.roOverland(:,tix);
fx.roSurfDir(:,tix)      =   (1-p.roSurf.rf) .* roOverland;

%--> fraction of surface storage that flows out irrespective of input
fx.wSurfRec(:,tix)       =   p.roSurf.rf .* roOverland;
fx.roSurfIndir(:,tix)    =   p.roSurf.dc .* s.w.wSurf;

%--> update surface water storage
s.w.wSurf               =   s.w.wSurf + fx.wSurfRec(:,tix) - fx.roSurfIndir(:,tix);

%--> get the total surface runoff 
fx.roSurf(:,tix)         =   fx.roSurfDir(:,tix) + fx.roSurfIndir(:,tix);

end
