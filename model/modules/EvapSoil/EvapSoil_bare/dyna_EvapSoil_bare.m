function [f,fe,fx,s,d,p] = dyna_EvapSoil_bare(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: evaporation from bare soil
%
% REFERENCES: ??
%
% CONTACT	: ttraut
%
% INPUT
% PETsoil   : potential evaporation from the soil surface [mm/time]
%           (fe.EvapSoil.PETsoil)
% wSoil    : soil moisture sum of all layers [mm]
%           (s.w.wSoil)
% ks       : evaporation resistance of soil []
%           (p.EvapSoil.ks)
%
% OUTPUT
% EvapSoil  : bare soil evaporation [mm/time]
%           (fx.EvapSoil)
% wSoil     : soil moisture sum of all layers [mm]
%           (s.w.wSoil)
%
% NOTES:
%
% #########################################################################


% scale the potential with the moisture status and take the minimum of what
% is available
fx.EvapSoil(:,tix) = min(fe.EvapSoil.PETsoil(:,tix), s.w.wSoil(:,1) .* p.EvapSoil.ks);

% update soil water pool
s.w.wSoil(:,1) = s.w.wSoil(:,1) - fx.EvapSoil(:,tix);


end
