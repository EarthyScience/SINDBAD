function [f,fe,fx,s,d,p] = prec_QoverFlow_BergstroemLinVegFr(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: calculates land surface runoff and infiltration to different soil layers
%
% REFERENCES: Bergstroem 1992
%
% CONTACT	: ttraut
%
% INPUT
% p.QoverFlow.berg_scale : scaling parameter to define p.berg from p.vegFr
% p.QoverFlow.smaxberg   : shape parameter of runoff-infiltration curve []
% p.QoverFlow.smaxVeg 		: maximum plant available soil water  [mm]
% p.QoverFlow.smax1 		  : maximum water capacity of first soil layer  [mm]
% s.w.wSoil         : soil moisture of the layers [mm]
% s.w.wTotalSoil    : total soil moisture [mm]
% s.wd.WBP          : water balance pool [mm]
%
% OUTPUT
% p.QoverFlow.berg : shape parameter runoff-infiltration curve (Bergstroem)
% fx.QoverFlow   : runoff from land [mm/time]
% fx.InSoil1   : infiltration in first soil layer [mm/time]
% s.w.wSoil    : total soil moisture [mm]
% s.wd.WBP     : water balance pool [mm]
%
% NOTES:
%
% #########################################################################

% get p.berg as linear function of p.berg_scal and p.vegFr
p.QoverFlow.berg = max(0.1, p.QoverFlow.berg_scale .* p.pVeg.vegFr); 

end
