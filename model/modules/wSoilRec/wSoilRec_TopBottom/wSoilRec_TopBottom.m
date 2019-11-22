function [f,fe,fx,s,d,p] = wSoilRec_TopBottom(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: estimate recharge of available water content
%
% REFERENCES: ??
%
% CONTACT	: mjung
%
% INPUT
%   - s.w.wSoil  : soil moisture content of layers [mm]
%   - s.wd.p_wSoilBase_wAWC : maximum plant available water content of layers
% WBP       : water balance pool [mm]
%           (s.wd.WBP)
%
% OUTPUT
% s.smPools : soil moisture content of layers [mm]
% wSM      : soil moisture sum of all layers [mm]
%
% WBP       : water balance pool [mm]
%           (s.wd.WBP)
%
% NOTES:
%
% #########################################################################


% water refill from top to bottom
% upper layer
nSoilLayers = s.wd.p_wSoilBase_nSoilLayers;

for sl=1:nSoilLayers
    ip = min(s.wd.p_wSoilBase_wAWC(:,sl) - s.w.wSoil(:,sl),s.wd.WBP);
    s.w.wSoil(:,sl) = s.w.wSoil(:,sl) + ip;
    s.wd.WBP = s.wd.WBP - ip;
end

end