function [f,fe,fx,s,d,p] = wGW2wSurf_fracWgw(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculates the depletion of groundwater to the surface water
%
% Inputs:
%	- s.w.wSurf:            surface water storage
%	- s.w.wGW:              groundwater storage
%   - p.wGW2wSurf.drainGW:  parameter to estimate the drainage from groundwater to surface water, scales the baseflow param (dc)
%   - p.roSurf.dc:          drainage parameter from wSurf
%
% Outputs:
%   - fx.wGW2wSurf:         wGW to wSurf (always positive)
%     
%
% Modifies:
% 	- s.w.wSurf
%   - s.w.wGW 
%
% References:
%   -
%
% Created by:
%   - Tina Trautmann (ttraut)
%
% Versions:
%   - 1.0 on 04.02.2020 (ttraut): 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
fx.wGW2wSurf(:,tix)     =   p.wGW2wSurf.drainGW .* p.roSurf.dc .* s.w.wGW;

% update storages
s.w.wGW                 =   s.w.wGW - fx.wGW2wSurf(:,tix);
s.w.wSurf               =   s.w.wSurf + fx.wGW2wSurf(:,tix);

end
