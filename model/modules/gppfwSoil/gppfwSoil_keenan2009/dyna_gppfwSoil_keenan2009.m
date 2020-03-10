function [f,fe,fx,s,d,p] = dyna_gppfwSoil_keenan2009(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % calculate the soil moisture stress on gpp
    %
    % Inputs:
    %   - s.w.wSoil(:,1):             values of soil moisture current time step for the 1st soil layer
    %   - p.gppfwSoil.q:
    %   - s.wd.p_wSoilBase_wSat(:,1): the soil water content for the 1st soil layer 
    %                                 at which reductions in GPP are first evident
    %   - s.wd.p_wSoilBase_wWP(:,1):  wilting point of the 1st soil layer
    %
    % Outputs:
    %   - d.gppfwSoil.SMScGPP: soil moisture effect on GPP between 0-1
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
    Smax  = s.wd.p_wSoilBase_wSat(:,1);
    Smin  = s.wd.p_wSoilBase_wWP(:,1);
    d.gppfwSoil.SMScGPP(:,tix) = min(max(((max(s.w.wSoil(:,1),Smin)-Smin)./(Smax-Smin)).^ p.gppfwSoil.q,0),1);  
end