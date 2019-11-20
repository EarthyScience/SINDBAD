function [f,fe,fx,s,d,p] = prec_roOverland_none(f,fe,fx,s,d,p,info)
% #########################################################################
% calculates total overland runoff that passes to the surface storage
%
% Inputs:
%	- info: to set roOverland to zeros
%
% Outputs:
%   - fx.roOverland : runoff from land [mm/time]
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
% #########################################################################
fx.roOverland = info.tem.helpers.arrays.zerospixtix;
end

