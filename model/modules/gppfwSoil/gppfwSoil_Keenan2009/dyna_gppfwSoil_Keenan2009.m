function [f,fe,fx,s,d,p] = dyna_gppfwSoil_Keenan2009(f,fe,fx,s,d,p,info,tix)
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
    %    - Keenan, T., García, R., Friend, A. D., Zaehle, S., Gracia, 
    %      C., and Sabate, S.: Improved understanding of drought 
    %      controls on seasonal variation in Mediterranean forest 
    %      canopy CO2 and water fluxes through combined in situ 
    %      measurements and ecosystem modelling, Biogeosciences, 6, 1423–1444
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
    SM                          = sum(s.w.wSoil, 2);
    WP                          = sum(s.wd.p_wSoilBase_wWP, 2);
    Wsat                        = sum(s.wd.p_wSoilBase_wSat, 2);
    maxAWC                      = max(Wsat - WP, 0);
    Smax                        = p.gppfwSoil.sSmax .* maxAWC;
    Smin                        = p.gppfwSoil.sSmin .* Smax;    
    d.gppfwSoil.SMScGPP(:,tix)	= min(max(((max(SM,Smin) - Smin) ./ (Smax-Smin)) .^ p.gppfwSoil.q,0),1);
    
end
