function [fx,s,d]=SoilEvap_simple(f,fe,fx,s,d,p,info,i);
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
% wSM1      : soil moisture of top layer [mm]
%           (s.wSM1)
% AWC1      : maximum plant available water content in the top layer [mm]
%           (p.SOIL.AWC1)
% 
% OUTPUT
% ESoil     : bare soil evaporation [mm/time]
%           (fx.ESoil)
% 
% NOTES:
% 
% #########################################################################

% multiply equilibrium PET with alphaSoil and (1-fapar)
%PET_soil = f.PET(:,i) .* p.SoilEvap.alpha .* (1 - f.FAPAR(:,i) );

% scale the potential with the moisture status and take the minimum of what
% is available
fx.ESoil(:,i) = min( fe.SoilEvap.PETsoil(:,i) .* s.wSM1(:,i) ./ p.SOIL.AWC1 , s.wSM1(:,i) );

% update soil moisture of upper layer
s.wSM1(:,i) = s.wSM1(:,i) - fx.ESoil(:,i);

end