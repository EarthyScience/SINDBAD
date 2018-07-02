function [f,fe,fx,s,d,p] = dyna_EvapSub_GLEAM(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: estimate sublimation
% 
% REFERENCES: ??
% 
% CONTACT	: mjung
% 
% INPUT
% Rn        : net radiation [MJ/m2/time]
%           (f.Rn)
% wSWE      : snow pack [mm]
%           (s.w.wSnow)
% frSnow    : fraction of snow  [] (fractional)
%           (s.wd.wFrSnow)
% PTtermSub : Priestley-Taylor term [mm/MJ]
%           (fe.EvapSub.PTtermSub)
% 
% OUTPUT
% Subl      : sublimation flux [mm/time]
%           (fx.Subl)
% 
% NOTES:
% 
% #########################################################################

% PTterm=(fei.Delta./(fei.Delta+fei.Gamma))./fei.Lambda
% Then sublimation (mm/day) is calculated in GLEAM using a P.T. equation
fx.EvapSub(:,tix) = min(s.w.wSnow, fe.EvapSub.PTtermSub(:,tix) .* f.Rn(:,tix) .* s.wd.wFrSnow );

% update the snow pack
s.w.wSnow = s.w.wSnow - fx.EvapSub(:,tix);

end