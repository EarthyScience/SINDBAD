function [f,fe,fx,s,d,p] = roInf_kUnsat(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: calculates groundwater recharge as a fraction of roSat_Bergstroem (land runoff that does not increase soil moisture)
%
% REFERENCES:
%
% CONTACT	: ttraut
%
% INPUT
% roSat      : interflow resp. land runoff [mm/time]
%             (fx.roSat)
% rf:       : fraction of water that contributes to recharge [-]
%             (p.wGWRec.rf)
% wGW       : ground water pool [mm]
%           (s.w.wGW)
%
% OUTPUT
% Qdir      : direct runoff [mm/time]
%           (fx.Qdir)
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
% drain the excess moisture to GW

soilDOS                 =   s.w.wSoil(:,1) ./ s.wd.p_wSoilBase_wSat(:,1);
kSat                    =   s.wd.p_wSoilBase_kSat(:,1);
Beta                    =   s.wd.p_wSoilBase_Beta(:,1);
k_unsat                 =   feval(p.pSoil.kUnsatFuncH,p,info,soilDOS,kSat,Beta);    

fx.roInf(:,tix)         =   max(s.wd.WBP-k_unsat,0);

s.wd.WBP                =  s.wd.WBP - fx.roInf(:,tix);

end
