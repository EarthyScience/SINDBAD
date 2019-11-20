function [f,fe,fx,s,d,p] = dyna_evapSoil_bare(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: evaporation from bare soil
%
% REFERENCES: ??
%
% CONTACT	: ttraut
%
% INPUT
% PETsoil   : potential evaporation from the soil surface [mm/time]
%           (fe.evapSoil.PETsoil)
% wSoil    : soil moisture sum of all layers [mm]
%           (s.w.wSoil)
% ks       : evaporation resistance of soil []
%           (p.evapSoil.ks)
%
% OUTPUT
% evapSoil  : bare soil evaporation [mm/time]
%           (fx.evapSoil)
% wSoil     : soil moisture sum of all layers [mm]
%           (s.w.wSoil)
%
% NOTES:
%
% #########################################################################


% scale the potential with the moisture status and take the minimum of what
% is available
fx.evapSoil(:,tix) = min(fe.evapSoil.PETsoil(:,tix), s.w.wSoil(:,1) .* p.evapSoil.ks);

% update soil water pool
s.w.wSoil(:,1) = s.w.wSoil(:,1) - fx.evapSoil(:,tix);


end
