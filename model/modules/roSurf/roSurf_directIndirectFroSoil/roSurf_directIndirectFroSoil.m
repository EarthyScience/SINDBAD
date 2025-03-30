function [f,fe,fx,s,d,p] = roSurf_directIndirectFroSoil(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the runoff from surface water storage considering frozen soil
% fraction
%
% Inputs:
%	- fx.roOverland 
%   - fe.roSat.fracFrozen
%   - s.wd.wSurf
%
% Outputs:
%   - fx.roSurf and its direct and indirect components
%   - d.roSurf.fracFastQ fraction of fast runoff (depending on frozen soil
%   fraction and p.dc)
%
% Modifies:
% 	- s.w.wSurf
%
% References:
%	- 
%
% Created by:
%   - Tina Trautmann (ttraut)
%
% Versions:
%   - 1.0 on 03.12.2020 (ttraut)
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
%--> fraction of overland runoff that recharges the surface water and the
%fraction that flows out directly
roOverland                  =   fx.roOverland(:,tix);
d.roSurf.fracFastQ(:,tix)	=   (1-p.roSurf.rf) .* (1-fe.roSat.fracFrozen(:,tix)) + fe.roSat.fracFrozen(:,tix);
fx.roSurfDir(:,tix)         =   d.roSurf.fracFastQ(:,tix) .* roOverland;

%--> fraction of surface storage that flows out irrespective of input
fx.wSurfRec(:,tix)       =   (1 - d.roSurf.fracFastQ(:,tix)) .* roOverland;
fx.roSurfIndir(:,tix)    =   p.roSurf.dc .* s.w.wSurf;

%--> update surface water storage
s.w.wSurf               =   s.w.wSurf + fx.wSurfRec(:,tix) - fx.roSurfIndir(:,tix);

%--> get the total surface runoff 
fx.roSurf(:,tix)         =   fx.roSurfDir(:,tix) + fx.roSurfIndir(:,tix);

end
