function [fx,s,d] = SupplyTransp_Federer(f,fe,fx,s,d,p,info,i)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES: Federer et al 1982
% 
% CONTACT	: mjung
% 
% INPUT
% wSM      : soil moisture sum of all layers [mm]
% maxRate   : maximum transpiration rate [mm/day]
%           (p.SupplyTransp.maxRate)
% tAWC     : maximum available water content for plants (sum of all layers) [mm]
%           (p.SOIL.tAWC)
% 
% OUTPUT
% TranspS   : Supply limited transpiration [mm/time]
%           (d.SupplyTransp.TranspS)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

% T = maxRate*(SM1+SM2)/AWC12
d.SupplyTransp.TranspS(:,i) = p.SupplyTransp.maxRate .* s.wSM  ./ p.SOIL.tAWC;

end