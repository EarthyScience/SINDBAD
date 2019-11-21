function [f,fe,fx,s,d,p] = dyna_evapSoil_Snyder2000(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES: Snyder et al 2000
% 
% CONTACT	: mjung
% 
% INPUT
% ETsoil   : evaporation from the soil surface [mm/time]
%           (fe.evapSoil.ETsoil)
%   s.smPools :  soil moisture per layer [mm]
% wSM      : soil moisture sum of all layers [mm]

% 
% OUTPUT
% ESoil     : bare soil evaporation [mm/time]
%           (fx.ESoil)
% wSM      : soil moisture sum of all layers [mm]
% NOTES: should we assume that soil evap = PET_soil where soil is
% saturated? (saturated fraction ....)
% 
% #########################################################################

fx.evapSoil(:,tix) = min(fe.evapSoil.ETsoil(:,tix) , s.w.wSoil(:,1));
% update soil moisture of upper layer
s.w.wSoil(:,1) = s.w.wSoil(:,1) - fx.evapSoil(:,tix);
end