function [fx,s,d] = dyna_EvapSoil_DemSup(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: calculates evaporation from soil based on a demand-supply limited approach
% 
% REFERENCES: Teuling et al.
% 
% CONTACT	: ttraut
% 
% INPUT
% PETsoil   : potential evaporation from the soil surface [mm/time]
%           (fe.EvapSoil.PETsoil)
% wSM  		: total soil moisture [mm]
% 			(s.wSM)
% ETsup     : fraction of soil moisture available for evapotranspiration [1/time]
%           (p.EvapSoil.ETsup) (=et_sup)
% 
% OUTPUT
% ESoil     : bare soil evaporation [mm/time]
%           (fx.ESoil)
% wSM      	: total soil moisture [mm]
% 			(s.wSM)
%
% NOTES: check usage of (:,tix)
% 
% #########################################################################

% calculate soil evaporation depending of potential ET and soil moisture status
fx.ESoil(:,tix) 	=	min(fe.EvapSoil.PETsoil(:,tix), p.EvapSoil.ETsup.*s.wSM); 

% update soil moisture
s.wSM  = s.wSM  - fx.ESoil(:,tix);

end
