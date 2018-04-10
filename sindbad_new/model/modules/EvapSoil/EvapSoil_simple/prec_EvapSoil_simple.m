function [fe,fx,d,p] = prec_EvapSoil_simple(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES: ??
% 
% CONTACT	: mjung
% 
% INPUT
% PET       : potential evapotranspiration [mm/time]
%           (f.PET)
% alpha     : Priestley-Taylor coefficient []
%           (p.EvapSoil.alpha)
% FAPAR     : fraction of absorbed photosynthetically active radiation
%           [] (equivalent to "canopy cover" in Gash and Miralles)
%           (f.FAPAR)
% 
% OUTPUT
% PETsoil   : potential evaporation from the soil surface [mm/time]
%           (fe.EvapSoil.PETsoil)
% 
% NOTES:
% 
% #########################################################################

palpha              = p.EvapSoil.alpha * ones(1,info.forcing.size(2));
tmp                 = f.PET .* palpha .* (1 - f.FAPAR);
tmp(tmp<0)          = 0;
fe.EvapSoil.PETsoil = tmp;

end