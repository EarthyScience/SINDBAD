function [f, fe, fx, s, d, p] = dyna_cTauAct_simple(f, fe, fx, s, d, p, info, tix)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % combine all the effects that change the turnover rates (k)
    %
    % Inputs:
    %   - s.cd.p_cCycleBase_k:
    %   - s.cd.p_cTaufLAI_kfLAI:     LAI stressor values on the the turnover rates
    %   - s.cd.p_cTaufpSoil_kfSoil:  Soil texture stressor values on the the turnover rates
    %   - s.cd.p_cTaufpVeg_kfVeg:    Vegetation type stressor values on the the turnover rates
    %   - fe.cTaufTsoil.fT:          Air temperature stressor values on the the turnover rates
    %   - d.cTaufwSoil.fwSoil:       Soil moisture stressor values on the the turnover rates
    %
    % Outputs:
    %   - s.cd.p_cTauAct_k: values for actual turnover rates
    %
    % Modifies:
    %   - s.cd.p_cTauAct_k
    %
    % References:
    %   -
    %
    % Notes:
    % we are multiplying [nPix,nZix]x[nPix,1] should be OK!
    %
    % Created by:
    %   - ncarvalhais
    %
    %
    % Versions:
    %   - 1.0 on 12.01.2020 (sbesnard)
    %
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    s.cd.p_cTauAct_k = ...
        s.cd.p_cCycleBase_k .* ...
        s.cd.p_cTaufLAI_kfLAI .* ...
        s.cd.p_cTaufpSoil_kfSoil .* ...
        s.cd.p_cTaufpVeg_kfVeg .* ...
        fe.cTaufTsoil.fT(:, tix) .* ...
        s.cd.p_cTaufwSoil_fwSoil;

    s.cd.p_cTauAct_k = min(max(s.cd.p_cTauAct_k, 0), 1);

end %function
