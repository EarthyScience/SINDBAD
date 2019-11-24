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

% nSoilLayers                 =   s.wd.p_wSoilBase_nSoilLayers;
nSoilLayers                 =   info.tem.model.variables.states.w.nZix.wSoil;
for sl=1:nSoilLayers-1
    wSoilExc                =   max(s.w.wSoil(:,sl) - s.wd.p_wSoilBase_wSat(:,sl),0);
    s.w.wSoil(:,sl)         =   s.w.wSoil(:,sl) - wSoilExc;
    % soilDOS                 =   s.w.wSoil(:,sl) ./ s.wd.p_wSoilBase_wSat(:,sl);
    % kSat                    =   s.wd.p_wSoilBase_kSat(:,sl);
    % Beta                    =   s.wd.p_wSoilBase_Beta(:,sl);
    k_unsat                 =   feval(p.pSoil.kUnsatFuncH,s,p,sl);    
    drain                   =   nanmin(k_unsat,nanmax(s.w.wSoil(:,sl),0));
    % update storages
    s.w.wSoil(:,sl)         =   s.w.wSoil(:,sl)-drain;
    s.w.wSoil(:,sl+1)       =   s.w.wSoil(:,sl+1)+drain+wSoilExc;
end
end
