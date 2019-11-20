function [f,fe,fx,s,d,p] = dyna_evapInt_simple2(f,fe,fx,s,d,p,info,tix)
% for canopy interception evaporation (evapInt) everything is
% precomputed. This function only updates the WBP variable.
%
% Inputs:
%   - fx.evapInt: canopy interception evaporation [mm/time]
% 
%
% Outputs:
%   - 
%
% Modifies:
% 	- s.wd.WBP: updates the water balance pool [mm]
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

% update the available water
s.wd.WBP               =   s.wd.WBP - fx.evapInt(:,tix);

end
