function [f,fe,fx,s,d,p] = dyna_EvapSub_GLEAM(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% computes sublimation following GLEAM
%
% Inputs:
%	- f.Rn   :              net radiation [MJ/m2/time]
%   - fe.EvapSub.PTtermSub: Priestley-Taylor term [mm/MJ]
%   - s.wd.wSnowFrac:       snow cover fraction []
%
% Outputs:
%   - fx.EvapSub: sublimation [mm/time]
%
% Modifies:
% 	- s.w.wSnow: snow pack [mm]
%
% References:
%	- GLEAM, Miralles et al.
%
% Created by:
%   - Martin Jung (mjung@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%%
% #########################################################################

% PTterm=(fei.Delta./(fei.Delta+fei.Gamma))./fei.Lambda
% Then sublimation (mm/day) is calculated in GLEAM using a P.T. equation
fx.EvapSub(:,tix) = min(s.w.wSnow, fe.EvapSub.PTtermSub(:,tix) .* s.wd.wSnowFrac );

% update the snow pack
s.w.wSnow = s.w.wSnow - fx.EvapSub(:,tix);

end
