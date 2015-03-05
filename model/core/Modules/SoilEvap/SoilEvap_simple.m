function [fx,s,d] = SoilEvap_simple(f,fe,fx,s,d,p,info,i)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES: ??
% 
% CONTACT	: mjung
% 
% INPUT
% PETsoil   : potential evaporation from the soil surface [mm/time]
%           (fe.SoilEvap.PETsoil)
%s.smPools :  soil moisture per layer [mm]
% wSM      : soil moisture sum of all layers [mm]
% AWC      : maximum plant available water content per layer [mm]
%           (p.SOIL.AWC)
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
%PET_soil = f.PET(:,i) .* p.SoilEvap.alpha .* (1 - f.FAPAR(:,i) );

% scale the potential with the moisture status and take the minimum of what
% is available
fx.ESoil(:,i) = min( fe.SoilEvap.PETsoil(:,i) .* s.smPools(1).value ./ p.SOIL.AWC(1).value , s.smPools(1).value );

% update soil moisture of upper layer
s.smPools(1).value = s.smPools(1).value - fx.ESoil(:,i);
s.wSM = s.wSM - fx.ESoil(:,i)
end