function [f,fe,fx,s,d,p] = wSnwFr_binary(f,fe,fx,s,d,p,info,tix)
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
% wSWE      : snow water equivalent pool [mm of H2O]
%           (s.w.wSnow)
% 
% OUTPUT
% 
% NOTES:
% 
% #########################################################################

% first update the snow pack
s.w.wSnow = s.w.wSnow + f.Snow(:,tix);

% if there is snow, then snow fraction is 1, otherwise 0
s.wd.wSnwFr = double(s.w.wSnow > 0); % to clean

end % function
