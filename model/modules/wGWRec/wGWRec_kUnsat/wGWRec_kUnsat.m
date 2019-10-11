function [f,fe,fx,s,d,p] = wGWRec_kUnsat(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: calculates groundwater recharge as a fraction of Qint_Bergstroem (land runoff that does not increase soil moisture)
%
% REFERENCES:
%
% CONTACT	: ttraut
%
% INPUT
% Qint      : interflow resp. land runoff [mm/time]
%             (fx.Qint)
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

% drain the excess moisture to GW

wSoilExc = max(s.w.wSoil(:,wSoilend) - p.pSoil.smax2,0);

s.w.wSoil(:,wSoilend)   =   s.w.wSoil(:,wSoilend)-wSoilExc;

% calculate the reduction in hydraulic conductivity due to soil under
% saturation
k_unsatfrac             =  (s.w.wSoil(:,wSoilend) ./ p.pSoil.smax2) .^ (2.*p.pSoil.chb + 3);
k_unsatfrac             =   min(k_unsatfrac,1.);

% unsaturated hydraulic conductivity and GW downward recharge
k_unsat                 =   p.pSoil.kSat .* k_unsatfrac;
fx.QgwDrain(:,tix)        =   k_unsat;

% update storages
s.w.wSoil(:,wSoilend)   =   s.w.wSoil(:,wSoilend)-fx.QgwDrain(:,tix);
fx.QgwDrain(:,tix)        =   fx.QgwDrain(:,tix) + wSoilExc ;
s.w.wGW                 =   s.w.wGW + fx.QgwDrain(:,tix);

end
