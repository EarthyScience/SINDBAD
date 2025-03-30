function [f,fe,fx,s,d,p] = dyna_rootFrac_expCvegRoot(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% sets the maximum fraction of water that root can uptake from soil layers 
% according to total carbon in root (cVegRoot)
%
% Inputs:
%   - p.rootFrac.fracRoot2SoilD_max
%   - p.rootFrac.fracRoot2SoilD_min
%   - p.rootFrac.p.rootFrac.k_cVegRoot
%   - s.c.cEco
%   - s.wd.maxRootDepth (from prec_rootFrac_expCvegRoot)
%   - info.tem.model.variables.states.w.soilLayerDepths
%
% Outputs:
%   - s.wd.p_rootFrac_fracRoot2SoilD as nPix,nZix for wSoil
%
% Modifies:
% 	- s.wd.p_rootFrac_fracRoot2SoilD
%
% References:
%	-
%
% Created by:
%   - Sujan Koirala
%
% Versions:
%   - 1.0 on 28.04.2020
%				
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%

%--> get the soil characteristics information from input and maximum rooting depth
nSoilLayers = info.tem.model.variables.states.w.nZix.wSoil;
soilDepths = info.tem.model.variables.states.w.soilLayerDepths;

%--> create the arrays to fill in the soil properties
%--> set the properties
rootStop = 0;

cVegRootZix = info.tem.model.variables.states.c.zix.cVegRoot;
cVegRoot= sum(s.c.cEco(:,cVegRootZix),2);

for sl = 1:nSoilLayers
    soilD = sum(soilDepths(1:sl));
    if ~rootStop
        s.wd.p_rootFrac_fracRoot2SoilD(:, sl) = p.rootFrac.fracRoot2SoilD_max - (p.rootFrac.fracRoot2SoilD_max - p.rootFrac.fracRoot2SoilD_min) .* (exp(-p.rootFrac.k_cVegRoot .* cVegRoot));
    else
        s.wd.p_rootFrac_fracRoot2SoilD(:, sl) = s.wd.p_rootFrac_fracRoot2SoilD(:, sl) .* 0;
    end
    
    if soilD - s.wd.maxRootDepth >= 0
        rootStop = 1;
    end
    
end

end
