function [fx,s,d] = Sublimation_GLEAM(f,fe,fx,s,d,p,info,i)
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
%           (d.SnowCover.frSnow)
% PTtermSub : Priestley-Taylor term [mm/MJ]
%           (fe.Sublimation.PTtermSub)
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
fx.Subl(:,i) = max(0, fe.Sublimation.PTtermSub(:,i) .* f.Rn(:,i) .* d.SnowCover.frSnow(:,i) );

% update the snow pack
s.wSWE(:,i) = s.wSWE(:,i) - fx.Subl(:,i);

end