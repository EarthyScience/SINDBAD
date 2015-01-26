function [fx,s,d] = SupplyTransp_Federer(f,fe,fx,s,d,p,info,i)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES: Federer et al 1982
% 
% CONTACT	: mjung
% 
% INPUT
% wSM1      : soil moisture of top layer [mm]
%           (s.wSM1)
% wSM2      : soil moisture of bottom layer [mm]
%           (s.wSM2)
% maxRate   : maximum transpiration rate [mm/day]
%           (p.SupplyTransp.maxRate)
% AWC12     : maximum available water content for plants [mm]
%           (p.SOIL.AWC12)
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
d.SupplyTransp.TranspS(:,i) = p.SupplyTransp.maxRate .* ( s.wSM1 + s.wSM2 ) ./ ( p.SOIL.AWC12 );

end