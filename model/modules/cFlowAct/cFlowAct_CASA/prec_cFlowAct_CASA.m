function [f,fe,fx,s,d,p] = prec_cFlowAct_CASA(f,fe,fx,s,d,p,info)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % combine all the effects that change the transfers
    % between carbon pools
    %
    % Inputs:
    %   - p.cCycleBase.cFlowE:     transfer matrix for carbon at ecosystem level
    %   - s.cd.p_cFlowfpSoil_E:    effect of soil on transfer efficiency between pools
    %   - s.cd.p_cFlowfpVeg_E:     effect of soil on transfer efficiency between pools
    %   - s.cd.p_cFlowfpSoil_F:    effect of vegetation on transfer fraction between pools
    %   - s.cd.p_cFlowfpVeg_F      effect of vegetation on transfer fraction between pools
    %
    % Outputs:
    %   - s.cd.p_cFlowAct_E:       effect of soil and vegetation on transfer efficiency between pools
    %   - s.cd.p_cFlowAct_F:       effect of soil and vegetation on transfer fraction between pools
    %   - s.cd.p_cFlowAct_A:       effect of soil and vegetation on actual transfer rates between pools
    %
    % Modifies:
    %   - s.cd.p_cFlowAct_A
    %   - s.cd.p_cFlowAct_E
    %   - s.cd.p_cFlowAct_F
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
    %   - 1.0 on 13.01.2020 (sbesnard)
    %
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    %@nc : this needs to go in the full...

    % effects of soil and veg on the (microbial) efficiency of c flows between carbon pools
    tmp = repmat(reshape(p.cCycleBase.cFlowE, [1 size(p.cCycleBase.cFlowE)]), info.tem.helpers.sizes.nPix, 1, 1);
    s.cd.p_cFlowAct_E = tmp + s.cd.p_cFlowfpSoil_E + s.cd.p_cFlowfpVeg_E;
    % effects of soil and veg on the partitioning of c flows between carbon pools
    s.cd.p_cFlowAct_F = s.cd.p_cFlowfpSoil_F + s.cd.p_cFlowfpVeg_F;
    % if there is fraction (F) and efficiency is 0, make efficiency 1
    ndx = s.cd.p_cFlowAct_F > 0 & s.cd.p_cFlowAct_E == 0;
    s.cd.p_cFlowAct_E(ndx) = 1;
    % if there is not fraction, but efficiency exists, make fraction == 1 (should give an error if there are more than 1 flux out of this pool)
    ndx = s.cd.p_cFlowAct_E > 0 & s.cd.p_cFlowAct_F == 0;
    s.cd.p_cFlowAct_F(ndx) = 1;
    % build A
    s.cd.p_cFlowAct_A = s.cd.p_cFlowAct_F .* s.cd.p_cFlowAct_E;

    % transfers
    [taker, giver] = find(squeeze(sum(s.cd.p_cFlowAct_A > 0, 1)) >= 1);
    s.cd.p_cFlowAct_taker = taker;
    s.cd.p_cFlowAct_giver = giver;

    % if there is flux order check that is consistent
    if ~isfield(p.cCycleBase,'fluxOrder')
        p.cCycleBase.fluxOrder = 1:numel(taker);
    else
        if numel(p.cCycleBase.fluxOrder) ~= numel(taker)
            error(['ERR : cFlowAct_CASA : '...
                'numel(p.cCycleBase.fluxOrder) ~= numel(taker)'])
        end
    end
    
end %function
