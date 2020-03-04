function [f,fe,fx,s,d,p] = prec_cTaufpSoil_CASA(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % Compute soil texture effects on turnover rates (k) of cMicSoil
    %
    % Inputs:
    %   - s.wd.p_wSoilBase_CLAY:    values for clay soil texture      
    %   - s.wd.p_wSoilBase_SILT:    values for silt soil texture
    %   - p.cTaufpSoil.TEXTEFFA:    parameter for the soil texture efficiency
    %
    % Outputs:
    %   - s.cd.p_cTaufpSoil_kfSoil:  Soil texture stressor values on the the turnover rates 
    %
    % Modifies:
    %   - 
    %
    % References:
    %   - Potter, C. S., J. T. Randerson, C. B. Field, P. A. Matson, P. M.
    %     Vitousek, H. A. Mooney, and S. A. Klooster. 1993.  Terrestrial ecosystem
    %     production: A process model based on global satellite and surface data.
    %     Global Biogeochemical Cycles. 7: 811-841. 
    %
    % Created by:
    %   - ncarvalhais
    %
    % Versions:
    %   - 1.0 on 12.01.2020 (sbesnard)
    %
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%sujan: moving clay and silt from p.soilTexture to s.wd.p_wSoilBase.
CLAY                       =   mean(s.wd.p_wSoilBase_CLAY,2);
SILT                       =   mean(s.wd.p_wSoilBase_SILT,2);

% TEXTURE EFFECT ON k OF cMicSoil
s.cd.p_cTaufpSoil_kfSoil         = info.tem.helpers.arrays.onespixzix.c.cEco;
zix                             = info.tem.model.variables.states.c.zix.cMicSoil;
s.cd.p_cTaufpSoil_kfSoil(:,zix)    = (1 - (p.cTaufpSoil.TEXTEFFA .* (SILT + CLAY)));
% (ineficient, should be pix zix_mic)

end %function
