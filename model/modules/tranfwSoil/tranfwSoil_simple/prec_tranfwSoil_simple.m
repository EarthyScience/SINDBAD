function [f,fe,fx,s,d,p] = prec_tranfwSoil_simple(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: calculates transpiration as simple function of soil water and vegetation fraction
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
% alphaVeg  : plant specific alpha coefficient in Priestley Taylor
%           (p.tranfwSoil.alphaVeg)
%
% OUTPUT
% PETveg   : potential evapotranspiration from vegetated surface [mm/time]
%           (fe.tranfwSoil.PETveg)
%
% NOTES:
%
% #########################################################################

fe.tranfwSoil.PETveg     =   f.PET .* s.cd.vegFrac .* p.tranfwSoil.alphaVeg;

end
