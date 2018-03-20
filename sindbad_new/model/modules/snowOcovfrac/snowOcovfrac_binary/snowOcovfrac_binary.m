function [fx,s,d] = snowOcovfrac_binary(f,fe,fx,s,d,p,info,i)
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
%           (s.wSWE)
% 
% OUTPUT
% 
% NOTES:
% 
% #########################################################################

% first update the snow pack
s.wSWE = s.wSWE + f.Snow(:,i);

% if there is snow, then snow fraction is 1, otherwise 0
s.wFrSnow = double(s.wSWE > 0);

end % function
