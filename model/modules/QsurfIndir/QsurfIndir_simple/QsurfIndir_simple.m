function [f,fe,fx,s,d,p] = QsurfIndir_simple(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% computes runoff from a linear surface water storage
%
% Inputs:
%	- p.QsurfIndir.dc: delayed surface runoff coefficient [1/time]
%
% Outputs:
%   - fx.QsurfIndir: slow runoff from surface water storage [mm/time]
%
% Modifies:
% 	- s.w.wSurf: surface water pool [mm]
%
% References:
%	- 
%
% Created by:
%   - Tina Trautmann (ttraut@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%%
% #########################################################################


% simply assume that a fraction of the surface water pool is slow runoff
fx.QsurfIndir(:,tix) = p.QsurfIndir.dc .* s.w.wSurf;

% update the surface water pool
s.w.wSurf = s.w.wSurf - fx.QsurfIndir(:,tix);

end
