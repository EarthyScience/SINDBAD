function [f,fe,fx,s,d,p] = prec_roBase_none(f,fe,fx,s,d,p,info)
% #########################################################################
% calculates base runoff from land
%
% Inputs:
%	- info: to set roBase to zeros
%
% Outputs:
%   - fx.Qinf : runoff from land [mm/time]
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
fx.roBase    =   info.tem.helpers.arrays.zerospixtix;
s.w.wGW     =   info.tem.helpers.arrays.zerospix;
end