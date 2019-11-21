function [f,fe,fx,s,d,p] = prec_evapSoil_none(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES: ??
% 
% CONTACT	: mjung
% 
% INPUT
% 
% OUTPUT
% ESoil     : soil evaporation, none... [mm/time]
%           (fx.ESoil)
% 
% NOTES:
% 
% #########################################################################
fx.evapSoil = info.tem.helpers.arrays.zerospixtix;
end