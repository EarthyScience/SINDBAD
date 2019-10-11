function [f,fe,fx,s,d,p] = wSnowFrac_HTESSEL(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% PURPOSE	: compute the snow pack and fraction of snow cover.
% 
% REFERENCES:
% 
% CONTACT	: mjung
% 
% INPUT
% Snow      : snow fall [mm/time]
%           (f.Snow)
% pwSWE     : snow water equivalent of the previous time step [mm of H2O]
%           (s.prev.wSWE)
% wSWE      : snow water equivalent pool [mm of H2O]
%           (s.w.wSnow)
% CoverParam: snow cover parameter [mm]. Default value = 15
%           (p.Snow.CoverParam)
% 
% OUTPUT
% frSnow    : fraction of the snow pack that is snow [] (fractional)
%           (s.wd.wSnowFrac)
% 
% NOTES: this needs better documentation, like references, (skoirala)
% 
% #########################################################################

% first update the snow pack
s.w.wSnow = s.w.wSnow + f.Snow(:,tix);

% suggested by Sujan (after HTESSEL GHM)
s.wd.wSnowFrac = min(1, s.w.wSnow ./ p.wSnowFrac.CoverParam );

end
