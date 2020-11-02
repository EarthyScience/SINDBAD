function [f,fe,fx,s,d,p] = evapInt_vegFrac(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% computes canopy interception evaporation as a fraction of vegetation cover
%
% Inputs:
%   - s.cd.vegFrac
% 
% Outputs:
%   - 
%
% Modifies:
%     - s.wd.WBP: updates the water balance pool [mm]
%
% References:
%    - 
%
% Created by:
%   - Tina Trautmann (ttraut)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
%   - 1.1 on 27.11.2019 (skoiralal): moved contents from prec, handling of vegFrac from s.cd
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
%--> calculate interception loss
intCap                  =   p.evapInt.pInt .* s.cd.vegFrac;
fx.evapInt(:,tix)       =   min(intCap, fe.rainSnow.rain(:,tix));

% update the available water
s.wd.WBP               =   s.wd.WBP - fx.evapInt(:,tix);

end
