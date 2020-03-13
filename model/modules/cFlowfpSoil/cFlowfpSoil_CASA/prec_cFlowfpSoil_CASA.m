function [f,fe,fx,s,d,p] = prec_cFlowfpSoil_CASA(f,fe,fx,s,d,p,info)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % effects of soil that change the transfers
    % between carbon pools
    %
    % Inputs:
    %   - s.wd.p_wSoilBase_CLAY:              soil hydraulic properties for clay layer
    %   - s.wd.p_wSoilBase_SILT:              soil hydraulic properties for silt layer
    %   - p.cFlowfpSoil.effA:
    %   - p.cFlowfpSoil.effB:
    %   - p.cFlowfpSoil.effCLAY_cSoilSlow_A:
    %   - p.cFlowfpSoil.effCLAY_cSoilSlow_B:
    %   - p.cFlowfpSoil.effCLAY_cMicSoil_A:
    %   - p.cFlowfpSoil.effCLAY_cMicSoil_B:
    %
    % Outputs:
    %   - s.cd.p_cFlowfpSoil_E:               effect of soil on transfer efficiency between pools
    %   - s.cd.p_cFlowfpSoil_F:               effect of soil on transfer fraction between pools
    %
    % Modifies:
    %   - s.cd.p_cFlowfpSoil_E
    %   - s.cd.p_cFlowfpSoil_F
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

    % s.cd.p_cFlowfpSoil_fSoil = zeros(numel(info.tem.model.nPix),numel(info.tem.model.nZix));
    % s.cd.p_cFlowfpSoil_fSoil = info.tem.helpers.arrays.zerospixzix.c.cEco;
    % %sujan
    s.cd.p_cFlowfpSoil_E = repmat(info.tem.helpers.arrays.zerospixzix.c.cEco, 1, 1, ...
        info.tem.model.variables.states.c.nZix.cEco);
    s.cd.p_cFlowfpSoil_F = s.cd.p_cFlowfpSoil_E;

    %sujan: moving clay and silt from p.soilTexture to s.wd.p_wSoilBase.
    CLAY = mean(s.wd.p_wSoilBase_CLAY, 2);
    SILT = mean(s.wd.p_wSoilBase_SILT, 2);

    % CONTROLS FOR C FLOW TRANSFERS EFFICIENCY (E) AND FRACTION (F) BASED ON PARTICULAR TEXTURE PARAMETERS...
    %    SOURCE,        TARGET,         VALUE (increment in E and F caused by soil properties)
    aME = {...
        'cMicSoil', 'cSoilSlow', p.cFlowfpSoil.effA - (p.cFlowfpSoil.effB .* (SILT + CLAY)); ...
        'cMicSoil', 'cSoilOld', p.cFlowfpSoil.effA - (p.cFlowfpSoil.effB .* (SILT + CLAY)); ...
        };

    aMF = {...
        'cSoilSlow', 'cMicSoil', 1 - (p.cFlowfpSoil.effCLAY_cSoilSlow_A + (p.cFlowfpSoil.effCLAY_cSoilSlow_B .* CLAY)); ...
        'cSoilSlow', 'cSoilOld', p.cFlowfpSoil.effCLAY_cSoilSlow_A + (p.cFlowfpSoil.effCLAY_cSoilSlow_B .* CLAY); ...
        'cMicSoil', 'cSoilSlow', 1 - (p.cFlowfpSoil.effCLAY_cMicSoil_A + (p.cFlowfpSoil.effCLAY_cMicSoil_B .* CLAY)); ...
        'cMicSoil', 'cSoilOld', p.cFlowfpSoil.effCLAY_cMicSoil_A + (p.cFlowfpSoil.effCLAY_cMicSoil_B .* CLAY); ...
        };

    for vn = {'E', 'F'}
        %     switch vn{1}
        %         case 'E', aM = aME;
        %         case 'F', aM = aMF;
        %     end
        eval(['aM = aM' vn{:} ';']);

        for ii = 1:size(aM, 1)
            ndxSrc = info.tem.model.variables.states.c.zix.(aM{ii, 1});
            ndxTrg = info.tem.model.variables.states.c.zix.(aM{ii, 2});

            for iSrc = 1:numel(ndxSrc)

                for iTrg = 1:numel(ndxTrg)
                    s.cd.(['p_cFlowfpSoil_' vn{1}])(:, ndxTrg(iTrg), ndxSrc(iSrc)) = aM{ii, 3};
                end

            end

        end

    end

end %function
