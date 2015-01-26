function [fx,s,d] = RootUptake_TopBottom(f,fe,fx,s,d,p,info,i)
% #########################################################################
% PURPOSE	: extract the transpired water from the soil
% 
% REFERENCES:
% 
% CONTACT	: mjung, ncarval
% 
% INPUT
% wSM1      : soil moisture of top layer [mm]
%           (s.wSM1)
% wSM2      : soil moisture of bottom layer [mm]
%           (s.wSM2)
% wGWR      : ground water recharge pool [mm] 
%           (s.wGWR)
% 
% OUTPUT
% wSM1      : soil moisture of top layer [mm]
%           (s.wSM1)
% wSM2      : soil moisture of bottom layer [mm]
%           (s.wSM2)
% wGWR      : ground water recharge pool [mm] 
%           (s.wGWR)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################
% first deplete the upper layer
ET1         = min(fx.Transp(:,i),s.wSM1);
s.wSM1 = s.wSM1 - ET1;



% then extract it from the ground water that is in the root zone
ET          = fx.Transp(:,i) - ET1;
ET1         = min(ET,s.wGWR);
s.wGWR = s.wGWR - ET1;

% then extract if from lower layer
ET          = ET - ET1;
s.wSM2 = s.wSM2 - ET;

end