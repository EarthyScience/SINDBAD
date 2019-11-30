function [f,fe,fx,s,d,p] = wRootUptake_TopBottom(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: extract the transpired water from the soil
% 
% REFERENCES:
% 
% CONTACT	: mjung, ncarval
% 
% INPUT
%
% INPUT
%s.smPools  : soil moisture content of layers [mm]
% wSM      : soil moisture sum of all layers [mm]
%s.wd.p_wSoilBase_wAWC : maximum plant available water content of layers
% wGWR      : ground water recharge pool [mm] 
%           (s.wd.wGWR)
%fx.tranAct  : transpiration [mm]
% OUTPUT
%s.smPools  : soil moisture content of layers [mm]
% wSM      : soil moisture sum of all layers [mm]
% wGWR      : ground water recharge pool [mm] 
%           (s.wd.wGWR)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################
% first extract it from ground water in the root zone
% VMC                      
% = minsb(maxsb((sum(s.w.wSoil .* s.wd.p_rootFrac_fracRoot2SoilD,2)
% - sum(s.wd.p_wSoilBase_wWP .* s.wd.p_rootFrac_fracRoot2SoilD,2)),0) ./ sum(s.wd.p_wSoilBase_wAWC .* s.wd.p_rootFrac_fracRoot2SoilD,2),1);
% AWC4Trans  = 

transp          = fx.tranAct(:,tix);

% 
% ET1         = minsb(ET,s.wd.wGWR);
% s.wd.wGWR = s.wd.wGWR - ET1;
% ET=ET-ET1;

%extract from top to bottom
for sl  =   1:size(s.w.wSoil,2)
    wSoilAvail      =   s.w.wSoil(:,sl) .* s.wd.p_rootFrac_fracRoot2SoilD(:,sl);
    contrib         =   minsb(transp,wSoilAvail);
    s.w.wSoil(:,sl) =   s.w.wSoil(:,sl) - contrib;
    transp          =   transp-contrib;    
end

end