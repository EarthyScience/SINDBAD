function [f,fe,fx,s,d,p] = dyna_cTaufwSoil_CASA(f,fe,fx,s,d,p,info,tix)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % Compute effect of soil moisture on soil decomposition as modelled in
    % CASA (BGME - below grounf moisture effect). The below ground
    % moisture effect, taken directly from the century model, uses
    % soil moisture from the previous month to determine a scalar
    % that is then used to determine the moisture effect on below
    % ground carbon fluxes. BGME is dependent on PET, Rainfall. This
    % approach is designed to work for Rainfall and PET values at the
    % monthly time step and it is necessary to scale it to meet that
    % criterion.
    %
    % Inputs:
    %   - fe.PET.PET:                      potential evapotranspiration (mm)
    %   - info.tem.model.time.nStepsYear:  number of time steps per year
    %   - p.cTaufwSoil.Aws:                parameter for curve (expansion/contraction) controlling
    %   - fe.rainSnow.rain:                rainfall
    %   - s.prev.s_w_wSoil:                soil moisture sum of all layers of previous time step [mm]
    %   - d.prev.d_cTaufwSoil_fwSoil:      previous time step below ground moisture effect on decomposition processes
    %
    % Outputs:
    %   - d.cTaufwSoil.fwSoil: values for below ground moisture effect on decomposition processes
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
    % Notes:
    % the BGME is used as a scalar dependent on soil moisture, as the
    % sum of soil moisture for all layers. This can be partitioned into
    % different soil layers in the soil and affect independently the
    % decomposition processes of pools that are at the surface and deeper in
    % the soils.
    %
    % Created by:
    %   - ncarvalhais
    %
    % Versions:
    %   - 1.0 on 12.01.2020 (sbesnard)
    %
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    % NUMBER OF TIME STEPS PER YEAR -> TIME STEPS PER MONTH
    TSPY = info.tem.model.time.nStepsYear; %sujan
    TSPM = TSPY ./ 12;

    % BELOW GROUND RATIO (BGRATIO) AND BELOW GROUND MOISTURE EFFECT (BGME)
    BGRATIO = info.tem.helpers.arrays.zerospix;
    BGME = info.tem.helpers.arrays.onespix;

    % PREVIOUS TIME STEP VALUES
    % pBGME    = s.prev.cTaufwSoil_fwSoil;
    pBGME = d.prev.d_cTaufwSoil_fwSoil; %sujan

    % FOR PET > 0
    ndx = (fe.PET.PET(:, tix) > 0);

    % COMPUTE BGRATIO
    BGRATIO(ndx) = (s.prev.s_w_wSoil(ndx, 1) ./ TSPM + fe.rainSnow.rain(ndx, tix)) ./ fe.PET.PET(ndx, tix);

    % ADJUST ACCORDING TO Aws
    BGRATIO = BGRATIO .* p.cTaufwSoil.Aws;

    % COMPUTE BGME
    ndx1 = ndx & (BGRATIO >= 0 & BGRATIO < 1);
    BGME(ndx1) = 0.1 + (0.9 .* BGRATIO(ndx1));
    ndx2 = ndx & (BGRATIO >= 1 & BGRATIO <= 2);
    BGME(ndx2) = 1;
    ndx3 = ndx & (BGRATIO > 2 & BGRATIO <= 30);
    BGME(ndx3) = 1 + 1/28 - 0.5/28 .* BGRATIO(ndx(ndx3));
    ndx4 = ndx & (BGRATIO > 30);
    BGME(ndx4) = 0.5;

    % WHEN PET IS 0, SET THE BGME TO THE PREVIOUS TIME STEP'S VALUE
    ndxn = (fe.PET.PET(:, tix) <= 0);
    BGME(ndxn) = pBGME(ndxn);
    BGME = max(min(BGME, 1), 0);

    % FEED IT TO THE STRUCTURE
    d.cTaufwSoil.fwSoil(:, tix) = BGME;
    % d.prev.cTaufwSoil_fwSoil    = BGME;
    % set the same moisture stress to all carbon pools
    s.cd.p_cTaufwSoil_fwSoil(:,info.tem.model.variables.states.c.zix.cEco) = d.cTaufwSoil.fwSoil(:,tix);

end
