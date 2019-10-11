function [f,fe,fx,s,d,p] = prec_EvapSoil_bare(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	:
%
% REFERENCES: ??
%
% CONTACT	: ttraut
%
% INPUT
% PET       : potential evapotranspiration [mm/time]
%           (f.PET)
% vegFr     : vegetation fraction of grid cell []
%           (p.pVeg.vegFr)
% ks        : evaporation resistance of soil
%           (p.EvapSoil.ks)
%
% OUTPUT
% PETsoil   : potential evaporation from the soil surface [mm/time]
%           (fe.EvapSoil.PETsoil)
%
% NOTES:
%
% #########################################################################

%p.EvapSoil.ks           =   p.EvapSoil.ks * info.tem.helpers.arrays.onestix;
fe.EvapSoil.PETsoil     =   f.PET .* (1-p.pVeg.vegFr);

end
