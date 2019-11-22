function [f,fe,fx,s,d,p] = wSoilRec_kUnsat(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: estimate recharge of available water content
%
% REFERENCES: ??
%
% CONTACT	: mjung
%
% INPUT
%   - s.w.wSoil  : soil moisture content of layers [mm]
%   - fe.wSoilBase.wAWC : maximum plant available water content of layers
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

% nSoilLayers                 =   fe.wSoilBase.nSoilLayers;
nSoilLayers                 =   info.tem.model.variables.states.w.nZix.wSoil;
for sl=1:nSoilLayers-1
    wSoilExc                =   max(s.w.wSoil(:,sl) - fe.wSoilBase.wSat(:,sl),0);
    s.w.wSoil(:,sl)         =   s.w.wSoil(:,sl) - wSoilExc;
    k_unsatfrac             =   (s.w.wSoil(:,sl) ./ fe.wSoilBase.wSat(:,sl)) .^ (2 ./ fe.wSoilBase.Alpha(:,sl) + 3);
    k_unsatfrac             =   nanmax(nanmin(k_unsatfrac,1.),0);
    % unsaturated hydraulic conductivity and downward recharge in soil
    k_unsat                 =   fe.wSoilBase.kSat(:,sl) .* k_unsatfrac;
    drain                   =   nanmin(k_unsat,nanmax(s.w.wSoil(:,sl),0));
    % update storages
    s.w.wSoil(:,sl)         =   s.w.wSoil(:,sl)-drain;
    s.w.wSoil(:,sl+1)       =   s.w.wSoil(:,sl+1)+drain+wSoilExc;
end

end