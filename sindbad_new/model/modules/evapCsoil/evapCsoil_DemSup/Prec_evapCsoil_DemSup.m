function [fe,fx,d,p] = prec_evapCsoil_DemSup(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: calculates evaporation from soil based on a demand-supply limited approach
% 
% REFERENCES: Teuling et al.
% 
% CONTACT	: ttraut
% 
% INPUT
% PET       : potential evaporation [mm/time]
%           (f.PET)
% ETalpha   : alpha factor of evapotranspiration [1/time]
%           (p.psoilR.ETalpha) (=p_et)
% 
% OUTPUT
% PETsoil   : potential evaporation from the soil surface [mm/time]
%           (fe.evapCsoil.PETsoil)
%
% NOTES: check usage of (:,tix)
% 
% #########################################################################

% calculate potential evaporation 
fe.evapCsoil.PETsoil 	=	max(0, f.PET .* (p.evapCsoil.ETalpha * ones(1,info.forcing.size(2)))); 

end