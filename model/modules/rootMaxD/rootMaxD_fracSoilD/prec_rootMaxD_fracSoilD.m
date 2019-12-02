function [f,fe,fx,s,d,p]=prec_rootMaxD_fracSoilD(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the maximum rooting depth as a fraction of total soil depth
%
% Inputs:
%   - p.rootMaxD.fracRootD2SoilD
%   - info.tem.model.variables.states.w.soilLayerDepths
%
% Outputs:
%   - s.wd.maxRootD: The maximum rooting depth as a fraction of total soil depth
%
% Modifies:
%     - None
% 
% References:
%    - 
%
% Created by:
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 21.11.2019
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%% 

%--> get the soil thickness and root distribution information from input
s.wd.maxRootD = sum(info.tem.model.variables.states.w.soilLayerDepths) .* p.rootMaxD.fracRootD2SoilD;    
end