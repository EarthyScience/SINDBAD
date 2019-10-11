function [f,fe,fx,s,d,p] = prec_totalEvap_SoilTran(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: create array for total evapotranspiration
%
% REFERENCES: ??
%
% CONTACT	: ttraut
%
% INPUT
% ET    : total evapotranspiration from land [mm/time]
%           (fx.ET)
%
% OUTPUT
% ET    : total evapotranspiration from land [mm/time]
%           (fx.ET)
%
% NOTES:
%
% #########################################################################

fx.ET = info.tem.helpers.arrays.nanpixtix;



end
