function [f,fe,fx,s,d,p] = prec_EvapSoil_DemSup(f,fe,fx,s,d,p,info)
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
%           (p.psoil.ETalpha) (=p_et)
% 
% OUTPUT
% PETsoil   : potential evaporation from the soil surface [mm/time]
%           (fe.EvapSoil.PETsoil)
%
% NOTES: check usage of (:,tix)
% 
% #########################################################################

% calculate potential evaporation 
fe.EvapSoil.PETsoil 	=	max(0, f.PET .* (p.EvapSoil.ETalpha * info.tem.helpers.arrays.onespixtix)); 

end