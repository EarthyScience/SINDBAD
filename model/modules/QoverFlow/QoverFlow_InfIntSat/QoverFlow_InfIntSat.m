function [f,fe,fx,s,d,p] = QoverFlow_InfIntSat(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% calculates total land surface runoff that passes to the surface storage
%
% Inputs:
%	- fx.Qinf: infiltration excess runoff
%	- fx.Qint: intermittent flow
%	- fx.Qsat: saturation excess runoff
%
% Outputs:
%   - fx.QoverFlow : runoff from land [mm/time]
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
fx.QoverFlow(:,tix)         =   fx.Qinf(:,tix) + fx.Qint(:,tix) + fx.Qsat(:,tix);
end
