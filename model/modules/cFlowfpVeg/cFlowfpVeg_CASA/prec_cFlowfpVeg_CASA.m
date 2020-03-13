function [f,fe,fx,s,d,p] = prec_cFlowfpVeg_CASA(f,fe,fx,s,d,p,info)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % effects of vegetation that change the transfers
    % between carbon pools
    %
    % Inputs:
    %   - s.cd.p_cTaufpVeg_MTF:              fraction of C in structural litter pools
    %                                        that will be metabolic from lignin:N ratio
    %   - s.cd.p_cTaufpVeg_SCLIGNIN:         fraction of C in structural litter pools from lignin
    %   - p.cFlowfpVeg.WOODLIGFRAC:          fraction of wood that is lignin
    %
    % Outputs:
    %   - s.cd.p_cFlowfpVeg_E:               effect of vegetation on transfer efficiency between pools
    %   - s.cd.p_cFlowfpVeg_F:               effect of vegetation on transfer fraction between pools
    %
    % Modifies:
    %   - s.cd.p_cFlowfpVeg_E
    %   - s.cd.p_cFlowfpVeg_F
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

    % s.cd.p_cFlowfpVeg_fVeg = zeros(nPix,numel(info.tem.model.c.nZix)); %sujan
    %s.cd.p_cFlowfpVeg_fVeg      =   info.tem.helpers.arrays.zerospixzix.c.cEco;
    s.cd.p_cFlowfpVeg_F = repmat(info.tem.helpers.arrays.zerospixzix.c.cEco, 1, 1, ...
        info.tem.model.variables.states.c.nZix.cEco);
    s.cd.p_cFlowfpVeg_E = s.cd.p_cFlowfpVeg_F;
    % ADJUST cFlow BASED ON PARTICULAR PARAMETERS...
    %   SOURCE,TARGET,INCREMENT...
    aM = {...
        'cVegLeaf', 'cLitLeafM', s.cd.p_cTaufpVeg_MTF; ...
        'cVegLeaf', 'cLitLeafS', 1 - s.cd.p_cTaufpVeg_MTF; ...
        'cVegWood', 'cLitWood', 1; ...
        'cVegRootF', 'cLitRootFM', s.cd.p_cTaufpVeg_MTF; ...
        'cVegRootF', 'cLitRootFS', 1 - s.cd.p_cTaufpVeg_MTF; ...
        'cVegRootC', 'cLitRootC', 1; ...
        'cLitLeafS', 'cSoilSlow', s.cd.p_cTaufpVeg_SCLIGNIN; ...
        'cLitLeafS', 'cMicSurf', 1 - s.cd.p_cTaufpVeg_SCLIGNIN; ...
        'cLitRootFS', 'cSoilSlow', s.cd.p_cTaufpVeg_SCLIGNIN; ...
        'cLitRootFS', 'cMicSoil', 1 - s.cd.p_cTaufpVeg_SCLIGNIN; ...
        'cLitWood', 'cSoilSlow', p.cFlowfpVeg.WOODLIGFRAC; ...
        'cLitWood', 'cMicSurf', 1 - p.cFlowfpVeg.WOODLIGFRAC; ...
        'cLitRootC', 'cSoilSlow', p.cFlowfpVeg.WOODLIGFRAC; ...
        'cLitRootC', 'cMicSoil', 1 - p.cFlowfpVeg.WOODLIGFRAC; ...
        'cSoilOld', 'cMicSoil', 1; ...
        'cLitLeafM', 'cMicSurf', 1; ...
        'cLitRootFM', 'cMicSoil', 1; ...
        'cMicSurf', 'cSoilSlow', 1; ...
        };

    for ii = 1:size(aM, 1)
        ndxSrc = info.tem.model.variables.states.c.zix.(aM{ii, 1});
        ndxTrg = info.tem.model.variables.states.c.zix.(aM{ii, 2}); %sujan is this 2 or 1?

        for iSrc = 1:numel(ndxSrc)

            for iTrg = 1:numel(ndxTrg)
                %             s.cd.p_cFlowfpVeg_fVeg(ndxTrg(iTrg),ndxSrc(iSrc)) = aM{ii,3};

                s.cd.p_cFlowfpVeg_F(:, ndxTrg(iTrg), ndxSrc(iSrc)) = aM{ii, 3}; %sujan
            end

        end

    end

end %function
