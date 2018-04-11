function [fx,s,d] = dyna_EvapSoil_simple(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES: ??
% 
% CONTACT	: mjung
% 
% INPUT
% PETsoil   : potential evaporation from the soil surface [mm/time]
%           (fe.EvapSoil.PETsoil)
%s.smPools :  soil moisture per layer [mm]
% wSM      : soil moisture sum of all layers [mm]
% AWC      : maximum plant available water content per layer [mm]
%           (p.psoil.AWC)
% 
% OUTPUT
% ESoil     : bare soil evaporation [mm/time]
%           (fx.ESoil)
%s.smPools :  soil moisture per layer [mm]
% wSM      : soil moisture sum of all layers [mm]
% 
% NOTES:
% 
% #########################################################################

% multiply equilibrium PET with alphaSoil and (1-fapar)
%PET_soil = f.PET(:,tix) .* p.EvapSoil.alpha .* (1 - f.FAPAR(:,tix) );

% scale the potential with the moisture status and take the minimum of what
% is available
fx.ESoil(:,tix) = min( fe.EvapSoil.PETsoil(:,tix) .* s.smPools(1).value ./ p.psoil.AWC(1).value , s.smPools(1).value );

% update soil moisture of upper layer
s.smPools(1).value = s.smPools(1).value - fx.ESoil(:,tix);
s.w.wSoil = s.w.wSoil - fx.ESoil(:,tix);
end