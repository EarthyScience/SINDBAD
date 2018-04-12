function [f,fe,fx,s,d,p] = prec_Qsnw_simple(f,fe,fx,s,d,p,info)
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
%           (p.Qsnw.Rate)
% timeStep  : model time step [days]
%           (info.timeScale.timeStep)
% 
% OUTPUT
% Tterm     : effect of temperature on snow melt [mm/time]
%           (fe.Qsnw.Tterm)
% 
% NOTES: may not be working well for longer time scales (like for weekly or
% longer time scales). Warnings needs to be set accordingly.
% 
% #########################################################################

% effect of temperature on snow melt = QsnwRate * Tair
pRate               = (p.Qsnw.Rate .* info.timeScale.timeStep) * ones(1,info.forcing.size(2));
fe.Qsnw.Tterm	= max(pRate .* f.Tair,0);

end