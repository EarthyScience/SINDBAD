function [f,fe,fx,s,d,p] = prec_evapInt_simple2(f,fe,fx,s,d,p,info)
% #########################################################################
% computes canopy interception evaporation according to the Gash model, 
% yet using a parameter p.vegFr instead of fAPAR forcing
%
% Inputs:
%   - fe.rainSnow.rain: rain fall [mm/time]
%	- p.pVeg.vegFr:     "canopy cover", vegetation fraction of the grid cell
%   - p.evapInt.pInt:   maximum storage capacity for a fully developed
%                       canopy [mm]
% 
%
% Outputs:
%   - fx.evapInt: canopy interception evaporation [mm/time]
%
% Modifies:
% 	- 
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


% interception evaporation is simply the minimum of the vegetation fraction dependent
% storage and the rainfall
fe.evapInt.IntCap   =   (p.evapInt.pInt * info.tem.helpers.arrays.onespixtix) .* p.pVeg.vegFr;
fx.evapInt          =   min(fe.evapInt.IntCap, fe.rainSnow.rain);

end
