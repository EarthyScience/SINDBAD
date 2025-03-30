function [f,fe,fx,s,d,p] = prec_cTaufTsoil_Q10(f,fe,fx,s,d,p,info)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % Compute effect of temperature on psoil carbon fluxes
    %
    % Inputs:
    %   - f.Tair:            values for air temperature
    %   - p.cTaufTsoil.Q10:  parameter for
    %   - p.cTaufTsoil.Tref: parameter for
    %
    % Outputs:
    %   - fe.cTaufTsoil.fT: air temperature stressor on turnover rates (k)
    %
    % Modifies:
    %   -
    %
    % References:
    %   -
    %
    % Notes:
    % - WE NEED TO CHECK THIS CODE OUT! NORMALIZATION FOR TREF WHEN
    %   OPTIMIZING Q10: NEEDED!!!
    %
    % Created by:
    %   - ncarvalhais
    %
    % Versions:
    %   - 1.0 on 12.01.2020 (sbesnard)
    %
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    % CALCULATE EFFECT OF TEMPERATURE ON psoil CARBON FLUXES
    fe.cTaufTsoil.fT = p.cTaufTsoil.Q10.^((f.Tair - p.cTaufTsoil.Tref) ./ 10);

end
