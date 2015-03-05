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
% wSM1      : soil moisture of top layer [mm]
%           (s.wSM1)
% 
% OUTPUT
% ESoil     : bare soil evaporation [mm/time]
%           (fx.ESoil)
% 
% NOTES: should we assume that soil evap = PET_soil where soil is
% saturated? (saturated fraction ....)
% 
% #########################################################################


fx.ESoil(:,i) = min( fe.SoilEvap.ETsoil(:,i) , s.wSM1 );

% update soil moisture of upper layer
s.wSM1 = s.wSM1 - fx.ESoil(:,i);

end