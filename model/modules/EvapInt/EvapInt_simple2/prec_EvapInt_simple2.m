function [f,fe,fx,s,d,p] = prec_EvapInt_simple2(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: compute canopy interception evaporation according to the Gash
% model, yet using a parameter p.vegFr instead of fAPAR forcing
%
% REFERENCES: ??
%
% CONTACT	: ttraut
%
% INPUT
% vegFr     : "canopy cover", vegetation fraction of the grid cell
%           (p.vegFr)
% pInt      : maximum storage capacity for a fully developed
%           canopy [mm] (warning: this is per rain event)
%           (p.EvapInt.pInt)
%
% OUTPUT
% IntCap    : canopy interception capacity [mm]
%           (fe.EvapInt.IntCap)
%
% NOTES:
%
% #########################################################################


% interception evaporation is simply the minimum of the vegetation fraction dependent
% storage and the rainfall
fe.EvapInt.IntCap             =   (p.EvapInt.pInt * info.tem.helpers.arrays.onespixtix) .* p.pVeg.vegFr;


end
