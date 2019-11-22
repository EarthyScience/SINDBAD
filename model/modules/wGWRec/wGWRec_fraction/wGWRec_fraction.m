function [f,fe,fx,s,d,p] = wGWRec_fraction(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: calculates groundwater recharge as a fraction of roSat_Bergstroem (land runoff that does not increase soil moisture)
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
%           (fx.wGWrec)
% wGW       : ground water pool [mm]
%           (s.w.wGW)
% WBP       : water balance pool [mm]
%           (s.wd.WBP)
%
% NOTES:
%
% #########################################################################

% calculate recharge
wSoilEnd  = size(s.w.wSoil,2)
fx.wGWRec(:,tix)  = p.wGWRec.rf .* s.w.wSoil(:,wSoilEnd);
fx.QgwDrain(:,tix)  = fx.wGWRec(:,tix);

% update groundwater pool
s.w.wSoil(:,wSoilEnd) = s.w.wSoil(:,wSoilEnd)- fx.wGWRec(:,tix);
s.w.wGW = s.w.wGW + fx.wGWRec(:,tix);

end
