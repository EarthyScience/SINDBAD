function [f,fe,fx,s,d,p] = wSnowFrac_binary(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% compute the snow pack and fraction of snow cover.
%
% Inputs:
%   - fe.rainSnow.snow      : snow fall [mm/time]
%
% Outputs:
%   - 
%
% Modifies:
% 	- s.w.wSnow:      updates the snow pack with snow fall
% 	- s.wd.wSnowFrac: sets wSnowFrac to 1 if there is snow, to 0 if there
% 	is now snow
%
% References:
%	- 
%
% Created by:
%   - Martin Jung (mjung)
%
% Versions:
%   - 1.0 on 18.11.2019 (ttraut): cleaned up the code
% 
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
% first update the snow pack
s.w.wSnow       = s.w.wSnow + fe.rainSnow.snow(:,tix);

% if there is snow, then snow fraction is 1, otherwise 0
s.wd.wSnowFrac  = double(s.w.wSnow > 0);

end
