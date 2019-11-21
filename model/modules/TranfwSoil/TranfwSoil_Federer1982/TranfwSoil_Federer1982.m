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
%           (fe.wSoilBase.wAWC)
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
d.TranfwSoil.TranActS(:,tix) = p.TranfwSoil.maxRate .* sum(s.w.wSoil .* fe.wSoilBase.fracRoot2SoilD,2)  ./ sum(fe.wSoilBase.wAWC .* fe.wSoilBase.fracRoot2SoilD,2);

end