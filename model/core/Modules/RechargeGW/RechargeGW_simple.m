function [fx,s,d] = RechargeGW_simple(f,fe,fx,s,d,p,info,i)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES:
% 
% CONTACT	: mjung
% 
% INPUT
% wGW       : ground water pool [mm] 
%           (s.wGW)
% WBP       : water balance pool [mm]
%           (d.Temp.WBP)
% 
% OUTPUT
% Qgwrec    : ground water recharge [mm/time]
%           (fx.Qgwrec)
% wGW       : ground water pool [mm] 
%           (s.wGW)
% WBP       : water balance pool [mm]
%           (d.Temp.WBP)
% 
% NOTES:
% 
% #########################################################################



% simply assume that all remaining (after having subtracted interception
% evap, infiltration excess runoff, saturation runoff, interflow, soil
% moisture recharge from (rainfall+snowmelt)) water goes to GW  
fx.Qgwrec(:,i) = d.Temp.WBP;
s.wGW(:,i) = s.wGW(:,i) + fx.Qgwrec(:,i);

end