function [f,fe,fx,s,d,p]=prec_rootMaxD_fracSoilD(f,fe,fx,s,d,p,info)
% sets the maximum fraction of water that root can uptake from soil layers
%
% Inputs:
%   - p.pSoil.thetaSat/kSat/psiSat/sSat
%   - p.pSoil.thetaFC/kFC/psiFC/sFC
%   - p.pSoil.thetaWP/kWP/psiWP/sWP
%
% Outputs:
%   - same as inputs per layer of soil depth in s.wd.p_wSoilBase_(parameter_name)
%
% Modifies:
% 	- None
% 
% References:
%	- 
%
% Created by:
%   - Sujan Koirala (skoirala@bgc-jena.mpg.de)
%
% Versions:
%   - 1.0 on 21.11.2019
%
%% 

%--> get the soil thickness and root distribution information from input
s.wd.maxRootD = sum(info.tem.model.variables.states.w.soilLayerDepths) .* p.rootMaxD.fracRootD2SoilD;    
end