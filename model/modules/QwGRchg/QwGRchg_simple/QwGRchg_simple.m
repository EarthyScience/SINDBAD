function [f,fe,fx,s,d,p] = QwGRchg_simple(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: 
% 
% REFERENCES:
% 
% CONTACT	: mjung
% 
% INPUT
% wGW       : ground water pool [mm] 
%           (s.w.wGW)
% WBP       : water balance pool [mm]
%           (s.wd.WBP)
% 
% OUTPUT
% Qgwrec    : ground water recharge [mm/time]
%           (fx.Qgwrec)
% wGW       : ground water pool [mm] 
%           (s.w.wGW)
% WBP       : water balance pool [mm]
%           (s.wd.WBP)
% 
% NOTES:
% 
% #########################################################################



% simply assume that all remaining (after having subtracted interception
% evap, infiltration excess runoff, saturation runoff, interflow, soil
% moisture recharge from (rainfall+snowmelt)) water goes to GW  
fx.Qgwrec(:,tix) = s.wd.WBP;
s.w.wGW = s.w.wGW + fx.Qgwrec(:,tix);

end