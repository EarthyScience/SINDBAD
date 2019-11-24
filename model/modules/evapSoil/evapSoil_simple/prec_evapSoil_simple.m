function [f,fe,fx,s,d,p] = prec_evapSoil_simple(f,fe,fx,s,d,p,info)
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
%           (p.evapSoil.alpha)
% FAPAR     : fraction of absorbed photosynthetically active radiation
%           [] (equivalent to "canopy cover" in Gash and Miralles)
%           (s.cd.fAPAR)
% 
% OUTPUT
% PETsoil   : potential evaporation from the soil surface [mm/time]
%           (fe.evapSoil.PETsoil)
% 
% NOTES:
% 
% #########################################################################

% palpha                  =   p.evapSoil.alpha * info.tem.helpers.arrays.onestix;
% tmp                     =   f.PET .* palpha .* (1 - s.cd.fAPAR);
% tmp(tmp<0)              =   0;
% fe.evapSoil.PETsoil     =   tmp;

end