function [fe,fx,d,p] = Prec_SoilEvap_DemSup(f,fe,fx,s,d,p,info)
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
%           (p.SOIL.ETalpha) (=p_et)
% 
% OUTPUT
% PETsoil   : potential evaporation from the soil surface [mm/time]
%           (fe.SoilEvap.PETsoil)
%
% NOTES: check usage of (:,i)
% 
% #########################################################################

% calculate potential evaporation 
fe.SoilEvap.PETsoil 	=	max(0, f.PET .* (p.SoilEvap.ETalpha * ones(1,info.forcing.size(2)))); 

end