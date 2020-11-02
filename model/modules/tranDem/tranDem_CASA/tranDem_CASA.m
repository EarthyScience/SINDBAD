function [f,fe,fx,s,d,p] = tranDem_CASA(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% calculate the supply limited transpiration as function of volumetric soil content 
% and soil properties, as in the CASA model
%
% Inputs:
%   - s.w.wSoil : total soil moisture
%   - s.wd.pawAct: actual extractable water
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

VMC                                 =   min(max(sum(s.wd.pawAct,2),0)...
                                        ./ sum(s.wd.p_wSoilBase_wAWC,2),1);
RDR                                 =   (1 + mean(s.wd.p_wSoilBase_Alpha,2)) ./ (1 + mean(s.wd.p_wSoilBase_Alpha,2) .* (VMC .^ mean(s.wd.p_wSoilBase_Beta,2)));

d.tranDem.tranDem(:,tix)            =   fx.wSoilPerc(:,tix) + (fe.PET.PET(:,tix) - fx.wSoilPerc(:,tix)) .* RDR;
end