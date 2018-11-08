function [f,fe,fx,s,d,p] = QwSurfRchg_fraction(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: calculates groundwater recharge as a fraction of Qint_Bergstroem (land runoff that does not increase soil moisture)
%
% REFERENCES:
%
% CONTACT	: ttraut
%
% INPUT
% QinfExc   : land runoff [mm/time]
%             (fx.QinfExc)
% rf:       : fraction of water that contributes to recharge [-]
%             (p.QwSurfRchg.rf)
% wSurf     : surface water pool [mm]
%           (s.w.wSurf)
%
% OUTPUT
% Qfast     : fast runoff [mm/time]
%           (fx.Qfast)
% QsurfRchg : surface water recharge [mm/time]
%           (fx.QsurfRchg)
% wSurf     : surface water pool [mm]
%           (s.w.wSurf)
% WBP       : water balance pool [mm]
%           (s.wd.WBP)
%
% NOTES:
%
% #########################################################################

% calculate recharge
fx.QsurfRchg (:,tix)  = p.QwSurfRchg.rf .* fx.QinfExc(:,tix);

% calculate direct runoff
fx.Qfast (:,tix)  = (1-p.QwSurfRchg.rf) .* fx.QinfExc(:,tix);

% update groundwater pool
s.w.wSurf = s.w.wSurf + fx.QsurfRchg(:,tix);

end
