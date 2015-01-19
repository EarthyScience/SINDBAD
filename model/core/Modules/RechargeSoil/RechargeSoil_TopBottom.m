function [fx,s,d] = RechargeSoil_TopBottom(f,fe,fx,s,d,p,info,i)
% #########################################################################
% PURPOSE	: estimate recharge of available water content 
% 
% REFERENCES: ??
% 
% CONTACT	: mjung
% 
% INPUT
% AWC1      : maximum plant available water content in the top layer [mm]
%           (p.SOIL.AWC1)
% AWC2      : maximum plant available water content in the bottom layer [mm]
%           (p.SOIL.AWC2)
% wSM1      : soil moisture of top layer [mm]
%           (s.wSM1)
% wSM2      : soil moisture of bottom layer [mm]
%           (s.wSM2)
% WBP       : water balance pool [mm]
%           (d.Temp.WBP)
% 
% OUTPUT
% wSM1      : soil moisture of top layer [mm]
%           (s.wSM1)
% wSM2      : soil moisture of bottom layer [mm]
%           (s.wSM2)
% WBP       : water balance pool [mm]
%           (d.Temp.WBP)
% 
% NOTES:
% 
% #########################################################################


% water refill from top to bottom
% upper layer
ip = min( p.SOIL.AWC1 - s.wSM1(:,i) , d.Temp.WBP);
s.wSM1(:,i) = s.wSM1(:,i) + ip;
d.Temp.WBP = d.Temp.WBP - ip;


% lower layer
ip=min( p.SOIL.AWC2 - s.wSM2(:,i) , d.Temp.WBP );
s.wSM2(:,i) = s.wSM2(:,i) + ip;
d.Temp.WBP = d.Temp.WBP - ip;

end