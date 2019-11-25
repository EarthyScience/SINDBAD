function [f,fe,fx,s,d,p]=prec_rootFrac_constant(f,fe,fx,s,d,p,info)
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
constantRootFrac                    =   info.tem.helpers.arrays.onespix .* p.rootFrac.constantRootFrac; % the fraction of water that a root can uptake from a soil layer
nSoilLayers                         =   info.tem.model.variables.states.w.nZix.wSoil;
soilDepths                          =   info.tem.model.variables.states.w.soilLayerDepths;

totalSoilDepth                      =   sum(soilDepths);
maxRootDepth                        =   min(s.wd.maxRootD,totalSoilDepth); % maximum rootingdepth

%--> create the arrays to fill in the soil properties
s.wd.p_rootFrac_fracRoot2SoilD     =   info.tem.helpers.arrays.onespixzix.w.wSoil;
%--> set the properties
for sl = 1:nSoilLayers
    soilD = sum(soilDepths(1:sl));
    if soilD < maxRootDepth
        s.wd.p_rootFrac_fracRoot2SoilD(:,sl)   =   s.wd.p_rootFrac_fracRoot2SoilD(:,sl) .* constantRootFrac;
    else
        s.wd.p_rootFrac_fracRoot2SoilD(:,sl)   =   s.wd.p_rootFrac_fracRoot2SoilD(:,sl) .* 0;
    end
end

end