function [fx,s,d] = dyna_EvapSub_GLEAM(f,fe,fx,s,d,p,info,tix)
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
%           (s.wSWE)
% frSnow    : fraction of snow  [] (fractional)
%           (s.wFrSnow)
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
fx.Subl(:,tix) = min(s.wSWE, fe.EvapSub.PTtermSub(:,tix) .* f.Rn(:,tix) .* s.wFrSnow );

% update the snow pack
s.wSWE = s.wSWE - fx.Subl(:,tix);

end