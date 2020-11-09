function [f,fe,fx,s,d,p] = prec_cTaufLAI_CASA(f,fe,fx,s,d,p,info)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % set LAI stressor on tau to ones
    %
    % Inputs:
    %   - info.timeScale.stepsPerYear:   number of years of simulations
    %
    % Outputs:
    %   - s.cd.p_cTaufLAI_kfLAI:

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
    %
    % Created by:
    %   - ncarvalhais
    %
    % Versions:
    %   - 1.0 on 12.01.2020 (sbesnard)
    %
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    % set LAI stressor on tau to ones
    s.cd.p_cTaufLAI_kfLAI = info.tem.helpers.arrays.onespixzix.c.cEco; %(inefficient, should be pix zix_veg)

    TSPY = info.tem.model.time.nStepsYear; %sujan
    
    s.cd.p_cTaufLAI_cVegLeafZix = info.tem.model.variables.states.c.zix.cVegLeaf;

    if isfield(info.tem.model.variables.states.c.zix, 'cVegRootF')
        s.cd.p_cTaufLAI_cVegRootZix = info.tem.model.variables.states.c.zix.cVegRootF;
    else
        s.cd.p_cTaufLAI_cVegRootZix = info.tem.model.variables.states.c.zix.cVegRoot;
    end

    % make sure TSPY is integer
    if rem(TSPY, 1) ~= 0, TSPY = floor(TSPY); end

    if ~isfield(s.cd, 'p_cTaufLAI_LAI13')
        s.cd.p_cTaufLAI_LAI13 = repmat(info.tem.helpers.arrays.zerospix, 1, TSPY + 1);
    end

end
