function [f,fe,fx,s,d,p] = Qsurf_all(f,fe,fx,s,d,p,info,tix)
% calculate the runoff from surface water storage
%
% Inputs:
%	% Inputs:
%	- fx.QoverFlow 
%   - s.wd.wSurf
%
% Outputs:
%   - fx.Qsurf 
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
%--> all overland flow becomes surface runoff
fx.Qsurf(:,tix)      =   fx.QoverFlow(:,tix);


end
