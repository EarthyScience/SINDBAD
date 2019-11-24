function [f,fe,fx,s,d,p] = dyna_evapSoil_simple(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES: ??
% 
% CONTACT	: mjung
% 
% INPUT
% PETsoil   : potential evaporation from the soil surface [mm/time]
%           (fe.evapSoil.PETsoil)
%s.smPools :  soil moisture per layer [mm]
% wSM      : soil moisture sum of all layers [mm]
% AWC      : maximum plant available water content per layer [mm]

% 
% OUTPUT
% ESoil     : bare soil evaporation [mm/time]
%           (fx.evapSoil)
%s.smPools :  soil moisture per layer [mm]
% wSM      : soil moisture sum of all layers [mm]
% 
% NOTES:
% 
% #########################################################################

% multiply equilibrium PET with alphaSoil and (1-fapar)
%PET_soil = f.PET(:,tix) .* p.evapSoil.alpha .* (1 - s.cd.fAPAR(:,tix) );
tmp                             =   f.PET(:,tix) .* p.evapSoil.alpha .* (1 - s.cd.fAPAR);
tmp(tmp<0)                      =   0;
fx.evapSoil.PETsoil(:,tix)      =   tmp;

% scale the potential with the moisture status and take the minimum of what
% is available
fx.evapSoil(:,tix)              =   min(fx.evapSoil.PETsoil(:,tix) .* s.w.wSoil(:,1) ./ s.wd.p_wSoilBase_wAWC(:,1) , s.w.wSoil(:,1));

% update soil moisture of the uppermost soil layer
s.w.wSoil(:,1)                  =   s.w.wSoil(:,1) - fx.evapSoil(:,tix);
end