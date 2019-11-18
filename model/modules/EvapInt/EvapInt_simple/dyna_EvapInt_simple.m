function [f,fe,fx,s,d,p] = dyna_EvapInt_simple(f,fe,fx,s,d,p,info,tix)
% for interception everything is precomputed. 
% This function only updates the WBP variable.
%
% Inputs:
%	- fx.EvapInt:    canopy interception evaporation [mm/time]
%
% Outputs:
%   - 
%
% Modifies:
% 	- s.wd.WBP:     water balance pool [mm]
%
% References:
%	- Gash model, Miralles et al 2010
%
% Created by:
%   - Martin Jung (mjung@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%
% NOTES: 
%   - Works per rain event. Here we assume that we have one rain event
%     per day - this approach should not be used for timeSteps very different
%     to daily.
%
%%
% #########################################################################

% update the available water
s.wd.WBP = s.wd.WBP - fx.EvapInt(:,tix);

end