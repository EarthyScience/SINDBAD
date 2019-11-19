function [f,fe,fx,s,d,p] = Qsurf_directIndirect(f,fe,fx,s,d,p,info,tix)
% calculate the runoff from surface water storage
%
% Inputs:
%	- fx.QoverFlow 
%   - s.wd.wSurf
%
% Outputs:
%   - fx.Qsurf and its direct and indirect components
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
QoverFlow               =   fx.QoverFlow(:,tix);
fx.QsurfDir(:,tix)      =   (1-p.Qsurf.rf) .* QoverFlow;

%--> fraction of surface storage that flows out irrespective of input
fx.wSurfRec(:,tix)      =   p.Qsurf.rf .* QoverFlow;
fx.QsurfIndir(:,tix)    =   p.Qsurf.dc .* s.w.wSurf;

%--> update surface water storage
s.w.wSurf               =   s.w.wSurf + fx.wSurfRec(:,tix) - fx.QsurfIndir(:,tix);

%--> get the total surface runoff 
fx.Qsurf(:,tix)         =   fx.QsurfDir(:,tix) + fx.QsurfIndir(:,tix);

end
