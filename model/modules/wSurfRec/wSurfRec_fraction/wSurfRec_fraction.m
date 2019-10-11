function [f,fe,fx,s,d,p] = wSurfRec_fraction(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: calculates groundwater recharge as a fraction of Qint_Bergstroem (land runoff that does not increase soil moisture)
%
% REFERENCES:
%
% CONTACT	: ttraut
%
% INPUT
% QoverFlow : overflow land runoff [mm/time]
%             (fx.QoverFlow)
% rf:       : fraction of water that contributes to recharge [-]
%             (p.wSurfRec.rf)
% wSurf     : surface water pool [mm]
%           (s.w.wSurf)
%
% OUTPUT
% QsurfDir     : fast runoff [mm/time]
%           (fx.QsurfDir)
% wSurfRec : surface water recharge [mm/time]
%           (fx.wSurfRec)
% wSurf     : surface water pool [mm]
%           (s.w.wSurf)
% WBP       : water balance pool [mm]
%           (s.wd.WBP)
%
% NOTES:
%
% #########################################################################

% calculate recharge
fx.wSurfRec(:,tix)  = p.wSurfRec.rf .* fx.QoverFlow(:,tix);

% calculate direct runoff
fx.QsurfDir(:,tix)  = (1-p.wSurfRec.rf) .* fx.QoverFlow(:,tix);

% update groundwater pool
s.w.wSurf = s.w.wSurf + fx.wSurfRec(:,tix);

end
