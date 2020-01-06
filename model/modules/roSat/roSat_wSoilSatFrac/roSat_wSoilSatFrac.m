function [f,fe,fx,s,d,p] = roSat_wSoilSatFrac(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the saturation excess runoff as a fraction of 
%
% Inputs:
%	- s.wd.wSoilSatFrac: fraction of the grid cell that is saturated
%   - s.wd.WBP: amount of incoming water
%
% Outputs:
%   - fx.roSat: saturation excess runoff in mm/day
%
% Modifies:
% 	- s.wd.WBP
%
% References:
%	- 
%
% Notes:
%   - only works if wSoilSatFrac module is activated
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 11.11.2019 (skoirala): cleaned up the code
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 
fx.roSat(:,tix) = s.wd.WBP .* s.wd.wSoilSatFrac;
% update the WBP
s.wd.WBP = s.wd.WBP - fx.roSat(:,tix);
end