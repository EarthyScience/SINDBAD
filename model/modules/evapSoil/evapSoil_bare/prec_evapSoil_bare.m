function [f,fe,fx,s,d,p] = prec_evapSoil_bare(f,fe,fx,s,d,p,info)
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
%           (s.cd.vegFrac)
% ks        : evaporation resistance of soil
%           (p.evapSoil.ks)
%
% OUTPUT
% PETsoil   : potential evaporation from the soil surface [mm/time]
%           (fe.evapSoil.PETsoil)
%
% NOTES:
%
% #########################################################################

%p.evapSoil.ks           =   p.evapSoil.ks * info.tem.helpers.arrays.onestix;


end
