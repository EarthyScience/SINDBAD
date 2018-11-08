function [f,fe,fx,s,d,p] = dyna_totalEvap_SoilTran(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: calculate total evapotranspiration
%
% REFERENCES: ??
%
% CONTACT	: ttraut
%
% INPUT
% Transp     : transpiration [mm/time]
%           (fx.Transp)
% EvapSoil   : soil evaporation [mm]
%           (fx.EvapSoil)
%
% OUTPUT
% ET    : total evapotranspiration from land [mm/time]
%           (fx.ET)
%
% NOTES:
%
% #########################################################################

fx.ET (:,tix) = fx.EvapSoil(:,tix) + fx.Transp(:,tix);



end
