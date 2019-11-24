function [f,fe,fx,s,d,p] = prec_evapInt_simple(f,fe,fx,s,d,p,info)
% #########################################################################
%  compute canopy interception evaporation according to the Gash
%   model
%
% Inputs:
%	- fe.rainSnow.rain:     rain fall [mm/time]
%   - s.cd.fAPAR:  fraction of absorbed photosynthetically active radiation [] 
%               (equivalent to "canopy cover" in Gash and Miralles)
% 	- p.evapInt.isp: maximum storage capacity for a fully developed
%                   canopy [mm] (warning: this is per rain event)
%
% Outputs:
%   - fx.evapInt:   canopy interception evaporation [mm/time]
%
% Modifies:
% 	- 
%
% References:
%	- Miralles et al 2010
%
% Created by:
%   - Martin Jung (mjung@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%
% Notes:
%   - Works per rain event. Here we assume that we have one rain event
%     per day - this approach should not be used for timeSteps very different
%       to daily.
%  - Parameters above, defaults in curly brackets from Miralles et al
%        2010
%%
% #########################################################################

% interception evaporation is simply the minimum of the fapar dependent
% storage and the rainfall
tmp             =   (p.evapInt.isp * info.tem.helpers.arrays.onestix) .* s.cd.fAPAR;
fx.evapInt      =   min(tmp,fe.rainSnow.rain);

end