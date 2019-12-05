function [f,fe,fx,s,d,p] = tranSup_CASA(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the supply limited transpiration as function of volumetric soil content 
% and soil properties, as in the CASA model
%
% Inputs:
%   - s.w.wSoil : total soil moisture
%   - s.wd.p_rootFrac_fracRoot2SoilD: extractable fraction of water
%   - s.wd.p_wSoilBase_wAWC: total maximum plant available water (FC-WP)
%   - s.wd.p_wSoilBase_[Alpha/Beta]: moisture retention characteristics
%
% Outputs:
%   - d.tranSup.tranSup: supply limited transpiration 
%
% Modifies:
%   - 
%
% References:
%   - 
%
% Notes:
%   - The supply limit has non-linear relationship with moisture state over the root zone
%
% Created by:
%   - Nuno Carvalhais (ncarval)
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): split the original tranSup of CASA into demand
%     supply: actual (minimum) is now just demSup approach of tranAct 
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%

VMC                                 =   minsb(maxsb((sum(s.w.wSoil .* s.wd.p_rootFrac_fracRoot2SoilD,2) - sum(s.wd.p_wSoilBase_wWP .* s.wd.p_rootFrac_fracRoot2SoilD,2)),0)...
                                        ./ sum(s.wd.p_wSoilBase_wAWC .* s.wd.p_rootFrac_fracRoot2SoilD,2),1);
RDR                                 =   (1 + mean(s.wd.p_wSoilBase_Alpha,2)) ./ (1 + mean(s.wd.p_wSoilBase_Alpha,2) .* (VMC .^ mean(s.wd.p_wSoilBase_Beta,2)));

d.tranSup.tranSup(:,tix)            =   minsb(sum(s.w.wSoil .* s.wd.p_rootFrac_fracRoot2SoilD,2) .* RDR, sum(s.w.wSoil .* s.wd.p_rootFrac_fracRoot2SoilD,2));
end