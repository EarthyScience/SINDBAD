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
fx.wGWrec(:,tix)  = p.wGWRec.rf .* fx.Qint(:,tix);

% calculate direct runoff
fx.Qdir(:,tix)  = (1-p.wGWRec.rf) .* fx.Qint(:,tix);

% update groundwater pool
s.w.wGW = s.w.wGW + fx.wGWRec(:,tix);

end
