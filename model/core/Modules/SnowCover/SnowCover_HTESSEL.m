function [fx,s,d]=SnowCover_HTESSEL(f,fe,fx,s,d,p,info,i);
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
%           (d.Temp.pwSWE)
% wSWE      : snow water equivalent pool [mm of H2O]
%           (s.wSWE)
% CoverParam: snow cover parameter [mm]. Default value = 15
%           (p.Snow.CoverParam)
% 
% OUTPUT
% frSnow    : fraction of the snow pack that is snow [] (fractional)
%           (d.SnowCover.frSnow)
% 
% NOTES: this needs better documentation, like references, (skoirala)
% 
% #########################################################################

% first update the snow pack
s.wSWE(:,i) = s.wSWE(:,i) + f.Snow(:,i);

% suggested by Sujan (after HTESSEL GHM)
d.SnowCover.frSnow(:,i) = min(1, s.wSWE(:,i) ./ p.SnowCover.CoverParam );

end
