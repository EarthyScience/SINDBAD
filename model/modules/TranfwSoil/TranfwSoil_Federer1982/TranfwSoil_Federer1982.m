function [f,fe,fx,s,d,p] = TranfwSoil_Federer1982(f,fe,fx,s,d,p,info,tix)
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
%           (p.TranfwSoil.maxRate)
% tAWC     : maximum available water content for plants (sum of all layers) [mm]
%           (fe.wSoilBase.sAWC)
% 
% OUTPUT
% TranActS   : Supply limited transpiration [mm/time]
%           (d.TranfwSoil.TranActS)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

% T = maxRate*(SM1+SM2)/AWC12
d.TranfwSoil.TranActS(:,tix) = p.TranfwSoil.maxRate .* sum(s.w.wSoil,2)  ./ sum(fe.wSoilBase.sAWC,2);

end