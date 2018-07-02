function [f,fe,fx,s,d,p] = dyna_EvapSoil_DemSup(f,fe,fx,s,d,p,info,tix)
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
% 			(s.w.wSoil)
% ETsup     : fraction of soil moisture available for evapotranspiration [1/time]
%           (p.EvapSoil.ETsup) (=et_sup)
% 
% OUTPUT
% ESoil     : bare soil evaporation [mm/time]
%           (fx.ESoil)
% wSM      	: total soil moisture [mm]
% 			(s.w.wSoil)
%
% NOTES: check usage of (:,tix)
% 
% #########################################################################

% calculate soil evaporation depending of potential ET and soil moisture status
fx.EvapSoil(:,tix) 	=	min(fe.EvapSoil.PETsoil(:,tix), p.EvapSoil.ETsup.*s.w.wSoil); 

% update soil moisture
s.w.wSoil  = s.w.wSoil  - fx.EvapSoil(:,tix);

end
