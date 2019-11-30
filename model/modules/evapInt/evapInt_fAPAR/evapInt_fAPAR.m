function [f,fe,fx,s,d,p] = dyna_evapInt_simple(f,fe,fx,s,d,p,info,tix)
% computes canopy interception evaporation as a fraction of fAPAR
%
% Inputs:
%	- fx.evapInt:    canopy interception evaporation [mm/time]
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
%%
% #########################################################################
%--> calculate interception loss
intCap                  =   p.evapInt.isp .* s.cd.fAPAR;
fx.evapInt(:,tix)       =   minsb(intCap, fe.rainSnow.rain(:,tix));

%--> update the available water
s.wd.WBP                =   s.wd.WBP - fx.evapInt(:,tix);
end