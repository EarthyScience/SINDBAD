function [f,fe,fx,s,d,p] = prec_roInf_none(f,fe,fx,s,d,p,info)
% #########################################################################
% calculates infiltration excess runoff from land
%
% Inputs:
%	- info: to set roInf to zeros
%
% Outputs:
%   - fx.roInf : runoff from land [mm/time]
%
% Modifies:
%
% References:
%
% Created by:
%   - Sujan Koirala (skoirala@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 18.11.2019 (skoirala)
%%
fx.roInf = info.tem.helpers.arrays.zerospixtix;
end

