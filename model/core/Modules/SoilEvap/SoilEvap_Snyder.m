function [fx,s,d] = SoilEvap_Snyder(f,fe,fx,s,d,p,info,i)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES: Snyder et al 2000
% 
% CONTACT	: mjung
% 
% INPUT
% ETsoil   : evaporation from the soil surface [mm/time]
%           (fe.SoilEvap.ETsoil)
%s.smPools :  soil moisture per layer [mm]
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


fx.ESoil(:,i) = min( fe.SoilEvap.ETsoil(:,i) , s.smPools(1).value );

% update soil moisture of upper layer
s.smPools(1).value = s.smPools(1).value - fx.ESoil(:,i);
s.wSM = s.wSM - fx.ESoil(:,i);

end