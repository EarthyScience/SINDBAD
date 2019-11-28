function [f,fe,fx,s,d,p] = tranfwSoil_Federer1982(f,fe,fx,s,d,p,info,tix)
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
%           (p.tranfwSoil.maxRate)
% tAWC     : maximum available water content for plants (sum of all layers) [mm]
%           (s.wd.p_wSoilBase_wAWC)
% 
% OUTPUT
% tranActS   : Supply limited transpiration [mm/time]
%           (d.tranfwSoil.TranSup)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

% T = maxRate*(SM1+SM2)/AWC12
d.tranfwSoil.TranSup(:,tix) = p.tranfwSoil.maxRate .* sum(s.w.wSoil .* s.wd.p_rootFrac_fracRoot2SoilD,2)  ./ sum(s.wd.p_wSoilBase_wAWC .* s.wd.p_rootFrac_fracRoot2SoilD,2);

end