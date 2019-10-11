function [f,fe,fx,s,d,p] = prec_Qsnow_simple(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: precompute the snow melt term
% 
% REFERENCES: ??
% 
% CONTACT	: mjung
% 
% INPUT
% Tair      : temperature [?C]
%           (f.Tair)
% Rate      : snow melt rate [mm/?C/day]
%           (p.Qsnow.Rate)
% timeStep  : model time step [days]
%           (info.timeScale.timeStep)
% 
% OUTPUT
% Tterm     : effect of temperature on snow melt [mm/time]
%           (fe.Qsnow.Tterm)
% 
% NOTES: may not be working well for longer time scales (like for weekly or
% longer time scales). Warnings needs to be set accordingly.
% 
% #########################################################################
% effect of temperature on snow melt = QsnowRate * Tair
pRate               = (p.Qsnow.Rate .* info.tem.model.time.nStepsDay) * info.tem.helpers.arrays.onestix;
%sujan pRate               = (p.Qsnow.Rate .* info.timeScale.timeStep) * info.tem.helpers.arrays.onestix;
fe.Qsnow.Tterm	= max(pRate .* f.Tair,0);

end