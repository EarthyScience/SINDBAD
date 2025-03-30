function [f, fe, fx, s, d, p] = cCycleConsistency_simple(f, fe, fx, s, d, p, info, tix)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % check consistency in cCycle matrix: cAlloc, cFlow
    %
    % Inputs:
    %	- s.cd.cAlloc:            carbon allocation matrix
    %   - flow_matrix:            carbon flow matrix
    %
    % Outputs:
    %   -
    %
    % Modifies:
    % 	-
    %
    % References:
    %	-
    %
    % Created by:
    %   - Simon Besnard (sbesnard)
    %
    % Versions:
    %   - 1.0 on 12.03.2020
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    % check allocation
    tmp0 = s.cd.cAlloc(:); %sujan
    tmp1 = sum(s.cd.cAlloc, 2);

    if any(tmp0 > 1) || any(tmp0 < 0)
        error('SINDBAD TEM: cAlloc lt 0 or gt 1')
    end

    if any(abs(sum(tmp1, 2) - 1) > 1E-6)
        error('SINDBAD TEM: sum(cAlloc) ne1')
    end

    % Check carbon flow matrix
    % the sum of A per column below the diagonals is always < 1
    % sujan: 22/03/2021: the flow_matrix reshape here is extremely slow..Also, it will not work when there is more than 1 pixel.
    for pix = 1:info.tem.helpers.sizes.nPix
        flow_matrix = squeeze(s.cd.p_cFlowAct_A(pix));
        flagUp = triu(ones(size(flow_matrix)), 1);
        flagLo = tril(ones(size(flow_matrix)), -1);
        % of diagonal values of 0 must be between 0 and 1
        anyBad = any(flow_matrix .* (flagLo + flagUp) < 0);

        if anyBad
            error('negative values in the p_cFlowAct_A matrix!')
        end

        anyBad = any(flow_matrix .* (flagLo + flagUp) > 1 + 1E-6);

        if anyBad
            error('values in the p_cFlowAct_A matrix greater than 1!')
        end

        % in the lower and upper part of the matrix A the sums have to be lower than 1
        anyBad = any(sum(flow_matrix .* flagLo, 1) > 1 + 1E-6);

        if anyBad
            error('sum of cols higher than one in lower in p_cFlowAct_A matrix')
        end

        anyBad = any(sum(flow_matrix .* flagUp, 1) > 1 + 1E-6);

        if anyBad
            error('sum of cols higher than one in upper in p_cFlowAct_A matrix')
        end

    end

    % flow_matrix = reshape(s.cd.p_cFlowAct_A, info.tem.model.variables.states.c.nZix.cEco, info.tem.model.variables.states.c.nZix.cEco);
    % flagUp = triu(ones(size(flow_matrix)),1);
    % flagLo     = tril(ones(size(flow_matrix)),-1);
    % % of diagonal values of 0 must be between 0 and 1
    % anyBad     = any(flow_matrix.*(flagLo+flagUp) < 0);
    % if anyBad
    %     error('negative values in the p_cFlowAct_A matrix!')
    % end
    % anyBad     = any(flow_matrix.*(flagLo+flagUp) > 1 + 1E-6);
    % if anyBad
    %     error('values in the p_cFlowAct_A matrix greater than 1!')
    % end
    % % in the lower and upper part of the matrix A the sums have to be lower than 1
    % anyBad     = any(sum(flow_matrix.*flagLo,1)>1 + 1E-6);
    % if anyBad
    %     error('sum of cols higher than one in lower in p_cFlowAct_A matrix')
    % end
    % anyBad     = any(sum(flow_matrix.*flagUp,1)>1 + 1E-6);
    % if anyBad
    %     error('sum of cols higher than one in upper in p_cFlowAct_A matrix')
    % end

end
