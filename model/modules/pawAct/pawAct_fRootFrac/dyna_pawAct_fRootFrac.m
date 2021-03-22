function [f,fe,fx,s,d,p]=dyna_pawAct_fRootFrac(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the actual amount of water that is available for plants
%
% Inputs:
%   - s.w.wSoil
%   - s.wd.p_
%
% Outputs:
%   - s.wd.p_rootFrac_fracRoot2SoilD as nPix,nZix for wSoil
%
% Modifies:
% 	- None
% 
% References:
%	- 
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 21.11.2019
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 

% %--> get the number of soil layers
% nSoilLayers                         =   info.tem.model.variables.states.w.nZix.wSoil;
% 
% for sl = 1:nSoilLayers
%     % wSoilAvail                      =   min(s.w.wSoil(:,sl),s.wd.p_wSoilBase_wAWC(:,sl));
%     s.wd.pawAct(:,sl)               =   s.wd.p_rootFrac_fracRoot2SoilD(:,sl) .* (max(s.w.wSoil(:,sl) - s.wd.p_wSoilBase_wWP(:,sl),0));
% end

s.wd.pawAct               =   s.wd.p_rootFrac_fracRoot2SoilD .* (max(s.w.wSoil - s.wd.p_wSoilBase_wWP,0));

end
