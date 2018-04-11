function [fe,fx,d,p,f] = prec_EvapSoil_none(f,fe,fx,s,d,p,info)
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

fx.ESoil = info.helper.zeros2d;

end