function [f,fe,fx,s,d,p] = dyna_gppfwSoil_Stocker2020(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % calculate the soil moisture stress on gpp
    %
    % Inputs:
    %   - s.w.wSoil:             values of soil moisture current time step
    %   - p.gppfwSoil.q:         parameters for sensitivity of GPP to SM 
    %   - p.gppfwSoil.Smax
    %   - p.gppfwSoil.Smin
    %   - s.wd.p_wSoilBase_wWP:  wilting point
    %
    % Outputs:
    %   - d.gppfwSoil.SMScGPP:   soil moisture effect on GPP between 0-1
    %
    % Modifies:
    %   - 
    %
    % References:
    %    - Stocker B D, Wang H, Smith N G, et al. P-model v1. 0: An optimality-based 
%     light use efficiency model for simulating ecosystem gross primary production[J]. Geos$
% 
    %
    % Notes: 
    %   - 
    %
    % Created by:
    %   - Nuno Carvalhais (ncarval) and Simon Besnard (sbesnard)
    %
    % Versions:
    %   - 1.0 on 10.03.2020 (sbesnard) 
    %
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

SM      = sum(s.w.wSoil, 2);
WP      = sum(s.wd.p_wSoilBase_wWP, 2);
WFC     = sum(s.wd.p_wSoilBase_wFC, 2);
maxAWC  = max(WFC - WP, 0);
actAWC  = max(SM - WP, 0);
SM_nor	= min(actAWC ./ maxAWC, 1);

fW      = (p.gppfwSoil.q .* (SM_nor - p.gppfwSoil.thetastar) .^ 2 + 1) .*...
        (SM_nor <= p.gppfwSoil.thetastar)...
        + 1 .* (SM_nor > p.gppfwSoil.thetastar);

d.gppfwSoil.SMScGPP(:,tix)	= max(0.0,min(1.0,fW));
% d.gppfwSoil.SM_nor(:,tix)	= SM_nor;
    
end
