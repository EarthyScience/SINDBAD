function [f,fe,fx,s,d,p] = dyna_EvapInt_simple2(f,fe,fx,s,d,p,info,tix)
% for canopy interception evaporation (EvapInt) everything is
% precomputed. This function only updates the WBP variable.
%
% Inputs:
%   - fx.EvapInt: canopy interception evaporation [mm/time]
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
s.wd.WBP               =   s.wd.WBP - fx.EvapInt(:,tix);

end
