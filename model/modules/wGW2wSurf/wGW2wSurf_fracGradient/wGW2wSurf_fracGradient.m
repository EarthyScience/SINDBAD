function [f,fe,fx,s,d,p] = wGW2wSurf_fracGradient(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the moisture exchange between groundwater and surface water as a fraction
% of difference between the storages
%
% Inputs:
%	- s.w.wSurf: surface water storage
%	- s.w.wGW: groundwater storage
%   - p.wGW2wSurf.kGW2Surf: moisture exchange coefficient
%
% Outputs:
%   - fx.wGW2wSurf: 
%       - positive: wGW to wSurf
%       - negative: wSurf to wGW
%
% Modifies:
% 	- s.w.wSurf
%   - s.w.wGW 
%
% References:
%   -
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 18.11.2019 (skoirala): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
fx.wGW2wSurf(:,tix)     =   p.wGW2wSurf.kGW2Surf .* (s.w.wGW - s.w.wSurf);

% update storages
s.w.wGW                 =   s.w.wGW - fx.wGW2wSurf(:,tix);
s.w.wSurf               =   s.w.wSurf + fx.wGW2wSurf(:,tix);

end
