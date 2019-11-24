function [f,fe,fx,s,d,p] = wGWRec_kUnsat(f,fe,fx,s,d,p,info,tix)
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
% calculate recharge

% index of the last soil layer
wSoilend                =   info.tem.model.variables.states.w.nZix.wSoil;
wSoilExc                =   max(s.w.wSoil(:,wSoilend) - ...
                            s.wd.p_wSoilBase_wSat(:,wSoilend),0);
s.w.wSoil(:,wSoilend)   =   s.w.wSoil(:,wSoilend)-wSoilExc;

%--> get the drainage
% kSat                    =   s.wd.p_wSoilBase_kSat(:,wSoilend);
% Beta                    =   s.wd.p_wSoilBase_Beta(:,wSoilend);

% soilDOS                 =   s.w.wSoil(:,wSoilend) ./ s.wd.p_wSoilBase_wSat(:,wSoilend);
k_unsat                 =   feval(p.pSoil.kUnsatFuncH,s,p,wSoilend);    
drain                   =   nanmin(k_unsat,nanmax(s.w.wSoil(:,wSoilend),0));
fx.QgwDrain(:,tix)      =   drain;

% update storages
s.w.wSoil(:,wSoilend)   =   s.w.wSoil(:,wSoilend)-fx.QgwDrain(:,tix);
fx.QgwDrain(:,tix)      =   fx.QgwDrain(:,tix) + wSoilExc ;
s.w.wGW                 =   s.w.wGW + fx.QgwDrain(:,tix);

end
