function [f,fe,fx,s,d,p] = prec_Qsat_none(f,fe,fx,s,d,p,info)
% set the saturation excess runoff to zeros outside the time loop
%
% Inputs:
%	- info.tem.helpers.arrays.zerospixtix: a helper array with zeros
%
% Outputs:
%   - fx.Qsat: saturation excess runoff in mm/day
%
% Modifies:
% 	- None
%
% References:
%	- 
%
% Created by:
%   - Sujan Koirala (skoirala@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 11.11.2019 (skoirala): cleaned up the code
%
%% 
fx.Qsat = info.tem.helpers.arrays.zerospixtix;
end