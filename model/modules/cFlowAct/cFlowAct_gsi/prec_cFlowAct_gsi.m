function [f, fe, fx, s, d, p] = prec_cFlowAct_gsi(f, fe, fx, s, d, p, info)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % Precomputations for the transfers
    % between carbon pools based on GSI method
    % Inputs:
    %   - p.cCycleBase.cFlowA:         transfer matrix for carbon at ecosystem level
    %
    % Outputs:
    %   - s.cd.p_cFlowAct_A:            updated transfer flow rate for carbon at ecosystem level
    %   - s.cd.p_cFlowAct_flowTable: a table with flow pools and parameters
    %   - s.cd.p_cFlowAct_ndxSrc: source pools
    %   - s.cd.p_cFlowAct_ndxTrg: taget pools;
    %   - s.cd.p_cFlowAct_flowVar: the variable that represents the flow between the source and target pool;
    % Modifies:
    %   - s.cd.p_cFlowAct_A
    %
    % References:
    %   -
    %
    % Created by:
    %   - ncarvalhais and skoirala
    %
    % Notes:
    %
    % Versions:
    %   - 1.0 on 13.01.2020 (sbesnard)
    %   - 1.1 on 05.02.2021 (skoirala): move code from dyna. Add table etc.
    %
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % see dyna_cFlowAct_gsi
    % Do A matrix
    s.cd.p_cFlowAct_A = repmat(reshape(p.cCycleBase.cFlowA, [1 size(p.cCycleBase.cFlowA)]), info.tem.helpers.sizes.nPix, 1, 1);

    % Prepare the list of flows
    asrc = ["cVegReserve" "cVegReserve" "cVegLeaf" "cVegRoot" "cVegLeaf" "cVegRoot"];
    atrg = ["cVegLeaf" "cVegRoot" "cVegReserve" "cVegReserve" "cLitFast" "cLitFast"];
    flowVar = ["Re2L;" "Re2R;" "L2ReF;" "R2ReF;" "k_LshedF;" "k_RshedF;"];
    flow = ones(numel(atrg), 1);
    ndxSrc = ones(numel(atrg), 1);
    ndxTrg = ones(numel(atrg), 1);
    flowTable = table(asrc', atrg', ndxSrc, ndxTrg, flowVar', flow, 'VariableNames', ["srcName", "trgName", "ndxSrc", "ndxTrg", "flowVar", "flow"]);

    for ii = 1:height(flowTable)
        ndxSrc = info.tem.model.variables.states.c.zix.(flowTable{ii, "srcName"});
        ndxTrg = info.tem.model.variables.states.c.zix.(flowTable{ii, "trgName"});
        flowTable{ii, "ndxSrc"} = ndxSrc;
        flowTable{ii, "ndxTrg"} = ndxTrg;

        for iSrc = 1:numel(ndxSrc)

            for iTrg = 1:numel(ndxTrg)
                fT = flowTable{ii, "flow"};
                s.cd.p_cFlowAct_A(:, ndxTrg(iTrg), ndxSrc(iSrc)) = fT(:);
            end

        end

    end

    aM = {info.tem.helpers.arrays.onespix; ...
            info.tem.helpers.arrays.onespix; ...
            info.tem.helpers.arrays.onespix; ...
            info.tem.helpers.arrays.onespix; ...
            info.tem.helpers.arrays.onespix; ...
            info.tem.helpers.arrays.onespix
        };

    s.cd.p_cFlowAct_flowTable = flowTable;
    s.cd.p_cFlowAct_ndxSrc = flowTable.ndxSrc;
    s.cd.p_cFlowAct_ndxTrg = flowTable.ndxTrg;
    s.cd.p_cFlowAct_flowVar = flowTable.flowVar;
    s.cd.p_cFlowAct_aM = aM;

    % transfers
    [taker, giver] = find(squeeze(sum(s.cd.p_cFlowAct_A > 0, 1)) >= 1);
    s.cd.p_cFlowAct_taker = taker;
    s.cd.p_cFlowAct_giver = giver;

    % if there is flux order check that is consistent
    if ~isfield(p.cCycleBase, 'fluxOrder')
        p.cCycleBase.fluxOrder = 1:numel(taker);
    else

        if numel(p.cCycleBase.fluxOrder) ~= numel(taker)
            error(['ERR:cFlowAct_gsi:' ...
                    'numel(p.cCycleBase.fluxOrder) ~= numel(taker)'])
        end

    end

end %function
