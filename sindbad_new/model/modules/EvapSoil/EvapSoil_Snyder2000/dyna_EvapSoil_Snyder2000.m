function [fx,s,d] = dyna_EvapSoil_Snyder2000(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES: Snyder et al 2000
% 
% CONTACT	: mjung
% 
% INPUT
% ETsoil   : evaporation from the soil surface [mm/time]
%           (fe.EvapSoil.ETsoil)
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


fx.ESoil(:,tix) = min( fe.EvapSoil.ETsoil(:,tix) , s.smPools(1).value );

% update soil moisture of upper layer
s.smPools(1).value = s.smPools(1).value - fx.ESoil(:,tix);
s.wSM = s.wSM - fx.ESoil(:,tix);

end