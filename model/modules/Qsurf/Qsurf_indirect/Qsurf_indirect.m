function [f,fe,fx,s,d,p] = Qsurf_indirect(f,fe,fx,s,d,p,info,tix)
% calculate the runoff from surface water storage
%
% Inputs:
%	- fx.QoverFlow 
%   - s.wd.wSurf
% Outputs:
%   - fx.Qsurf and its indirect/slow component
%
% Modifies:
% 	- s.w.wSurf
%
% References:
%	- 
%
% Created by:
%   - Sujan Koirala (skoirala@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 20.11.2019 (skoirala): combine QsurfDir,Indir, wSurfRec
%%
%--> fraction of overland runoff that recharges the surface water and the
%fraction that flows out directly
fx.wSurfRec(:,tix)      =   fx.QoverFlow(:,tix);

%--> fraction of surface storage that flows out as surface runoff 
fx.Qsurf(:,tix)         =   p.Qsurf.dc .* s.w.wSurf;

%--> update surface water storage
s.w.wSurf               =   s.w.wSurf + fx.wSurfRec(:,tix) - fx.QsurfIndir(:,tix);


end
