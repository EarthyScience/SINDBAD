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
%p.pSoil.AWC : maximum plant available water content of layers
% wGWR      : ground water recharge pool [mm] 
%           (s.wd.wGWR)
%fx.TranAct  : transpiration [mm]
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

ET          = fx.TranAct(:,tix);
ET1         = min(ET,s.wd.wGWR);
s.wd.wGWR = s.wd.wGWR - ET1;
ET=ET-ET1;

%extract from top to bottom
for ii=1:length(s.smPools)
    
    ET1         = min(ET,s.smPools(ii).value);
    s.smPools(ii).value = s.smPools(ii).value - ET1;
    ET=ET-ET1;
    
   s.w.wSoil = s.w.wSoil - ET1;
end






end