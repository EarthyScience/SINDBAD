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
    %   - Carvalhais, N., Reichstein, M., Seixas, J., Collatz, G. J., Pereira, J. S., Berbigier, P.,
    %       ... & Rambal, S. (2008). Implications of the carbon cycle steady state assumption for
    %       biogeochemical modeling performance and inverse parameter retrieval. Global Biogeochemical Cycles, 22(2).
    %   - Potter, C. S., Randerson, J. T., Field, C. B., Matson, P. A., Vitousek, P. M., Mooney, H. A.,
    %       & Klooster, S. A. (1993). Terrestrial ecosystem production: a process model based on global
    %       satellite and surface data. Global Biogeochemical Cycles, 7(4), 811-841.
    %   - Potter, C., Klooster, S., Myneni, R., Genovese, V., Tan, P. N., & Kumar, V. (2003).
    %       Continental-scale comparisons of terrestrial carbon sinks estimated from satellite data and ecosystem
    %       modeling 1982–1998. Global and Planetary Change, 39(3-4), 201-213.
    %
    % Created by:
    %   - ncarvalhais
    %
    % Versions:
    %   - 1.0 on 12.01.2020 (sbesnard)
    %
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    %sujan: moving clay and silt from p.soilTexture to s.wd.p_wSoilBase.
    CLAY = mean(s.wd.p_wSoilBase_CLAY, 2);
    SILT = mean(s.wd.p_wSoilBase_SILT, 2);

    % TEXTURE EFFECT ON k OF cMicSoil
    s.cd.p_cTaufpSoil_kfSoil = info.tem.helpers.arrays.onespixzix.c.cEco;
    zix = info.tem.model.variables.states.c.zix.cMicSoil;
    s.cd.p_cTaufpSoil_kfSoil(:, zix) = (1 - (p.cTaufpSoil.TEXTEFFA .* (SILT + CLAY)));
    % (ineficient, should be pix zix_mic)

end %function
