function [fx,s,d] = SoilEvap_DemSup(f,fe,fx,s,d,p,info,i)
% #########################################################################
% PURPOSE	: calculates evaporation from soil based on a demand-supply limited approach
% 
% REFERENCES: Teuling et al.
% 
% CONTACT	: ttraut
% 
% INPUT
% PETsoil   : potential evaporation from the soil surface [mm/time]
%           (fe.SoilEvap.PETsoil)
% wSM  		: total soil moisture [mm]
% 			(s.wSM)
% ETsup     : fraction of soil moisture available for evapotranspiration [1/time]
%           (p.SoilEvap.ETsup) (=et_sup)
% 
% OUTPUT
% ESoil     : bare soil evaporation [mm/time]
%           (fx.ESoil)
% wSM      	: total soil moisture [mm]
% 			(s.wSM)
%
% NOTES: check usage of (:,i)
% 
% #########################################################################

% calculate soil evaporation depending of potential ET and soil moisture status
fx.ESoil(:,i) 	=	min(fe.SoilEvap.PETsoil(:,i), p.SoilEvap.ETsup.*s.wSM); 

% update soil moisture
s.wSM  = s.wSM  - fx.ESoil(:,i);

end
