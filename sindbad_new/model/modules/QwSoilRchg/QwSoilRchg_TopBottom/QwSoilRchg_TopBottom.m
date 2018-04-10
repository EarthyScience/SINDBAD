function [fx,s,d] = QwSoilRchg_TopBottom(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: estimate recharge of available water content
%
% REFERENCES: ??
%
% CONTACT	: mjung
%
% INPUT
%s.smPools  : soil moisture content of layers [mm]
%p.psoil.AWC : maximum plant available water content of layers
% wSM      : soil moisture sum of all layers [mm]
% WBP       : water balance pool [mm]
%           (d.Temp.WBP)
%
% OUTPUT
% s.smPools : soil moisture content of layers [mm]
% wSM      : soil moisture sum of all layers [mm]
%
% WBP       : water balance pool [mm]
%           (d.Temp.WBP)
%
% NOTES:
%
% #########################################################################


% water refill from top to bottom
% upper layer


for ii=1:length(s.smPools)
    
    ip = min( p.psoil.AWC(ii).value - s.smPools(ii).value , d.Temp.WBP);
    s.smPools(ii).value = s.smPools(ii).value + ip;
    d.Temp.WBP = d.Temp.WBP - ip;
    
    s.wSM = s.wSM + ip;
end





end