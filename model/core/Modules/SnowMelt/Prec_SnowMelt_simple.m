function [fe,fx,d,p] = Prec_SnowMelt_simple(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: precompute the snow melt term
% 
% REFERENCES: ??
% 
% CONTACT	: mjung
% 
% INPUT
% Tair      : temperature [ºC]
%           (f.Tair)
% Rate      : snow melt rate [mm/ºC/day]
%           (p.SnowMelt.Rate)
% timeStep  : model time step [days]
%           (info.timeScale.timeStep)
% 
% OUTPUT
% Tterm     : effect of temperature on snow melt [mm/time]
%           (fe.SnowMelt.Tterm)
% 
% NOTES: may not be working well for longer time scales (like for weekly or
% longer time scales). Warnings needs to be set accordingly.
% 
% #########################################################################

% effect of temperature on snow melt = SnowMeltRate * Tair
pRate               = (p.SnowMelt.Rate .* info.timeScale.timeStep) * ones(1,info.forcing.size(2));
fe.SnowMelt.Tterm	= max(pRate .* f.Tair,0);

end