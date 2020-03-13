function [f,fe,fx,s,d,p] = cFlowAct_gsi(f,fe,fx,s,d,p,info,tix)
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % combine all the effects that change the transfers
    % between carbon pools based on GSI method
    % Inputs:
    %   - p.cCycleBase.cFlowA:         transfer matrix for carbon at ecosystem level
    %   - d.cAllocfwSoil.fW:           water stressors for carbon allocation
    %   - d.cAllocfTsoil.fT:           temperature stressors for carbon allocation
    %   - d.cAllocfRad.fR:             radiation stressors for carbo allocation
    %   - d.prev.d_cAllocfwSoil_fW:    previous water stressors for carbon allocation
    %   - d.prev.d_cAllocfTsoil_fT:    previous temperature stressors for carbon allocation
    %   - d.prev.d_cAllocfRad_fR:      previous radiation stressors for carbo allocation
    %   - p.cFlowAct.LR2ReSlp:         slope from leave/root to reserve
    %   - p.cFlowAct.Re2LRSlp:         slope from reserve to leave/roots
    %   - p.cFlowAct.kShed:            carbon allocation to litter from shedding
    %
    % Outputs:
    %   - s.cd.p_cFlowAct_A:            updated transfer matrix for carbon at ecosystem level
    %
    % Modifies:
    %   - s.cd.p_cFlowAct_A
    %
    % References:
    %   -
    %
    % Created by:
    %   - ncarvalhais and sbesnard
    %
    % Versions:
    %   - 1.0 on 13.01.2020 (sbesnard)
    %
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    % Estimate flows between reserve, leave, root and shed
    pcFlowAct_fWfTfR = d.prev.d_cAllocfwSoil_fW .* d.prev.d_cAllocfTsoil_fT .* d.prev.d_cAllocfRad_fR;
    cFlowAct.fWfTfR = d.cAllocfwSoil.fW(:, tix) .* d.cAllocfTsoil.fT(:, tix) .* d.cAllocfRad.fR(:, tix);
    LR2Re = min(max(pcFlowAct_fWfTfR - cFlowAct.fWfTfR, 0) .* p.cFlowAct.LR2ReSlp, 1); % if DAS degrades, mobilize c to reserves
    Re2LR = min(max(cFlowAct.fWfTfR - pcFlowAct_fWfTfR, 0) .* p.cFlowAct.Re2LRSlp, 1); % if DAS increases, mobilize c to leafs and roots
    kShed = min(max(pcFlowAct_fWfTfR - cFlowAct.fWfTfR, 0) .* p.cFlowAct.kShed, 1); % if DAS degrades increase c to litter

    % Do A matrix
    s.cd.p_cFlowAct_A = repmat(reshape(p.cCycleBase.cFlowA, [1 size(p.cCycleBase.cFlowA)]), info.tem.helpers.sizes.nPix, 1, 1);

    % Adjust cFlow between reserve, leave and root
    aM = {...
        'cVegReserve', 'cVegLeaf', Re2LR ./ 2; ...
        'cVegReserve', 'cVegRoot', Re2LR ./ 2; ...
        'cVegLeaf', 'cVegReserve', LR2Re ./ 2; ...
        'cVegRoot', 'cVegReserve', LR2Re ./ 2; ...
        };

    for ii = 1:size(aM, 1)
        ndxSrc = info.tem.model.variables.states.c.zix.(aM{ii, 1});
        ndxTrg = info.tem.model.variables.states.c.zix.(aM{ii, 2}); %sujan is this 2 or 1?

        for iSrc = 1:numel(ndxSrc)

            for iTrg = 1:numel(ndxTrg)
                s.cd.p_cFlowAct_A(:, ndxTrg(iTrg), ndxSrc(iSrc)) = aM{ii, 3}; %sujan
            end

        end

    end

    % transfers
    [taker, giver] = find(squeeze(sum(s.cd.p_cFlowAct_A > 0, 1)) >= 1);
    s.cd.p_cFlowAct_taker = taker;
    s.cd.p_cFlowAct_giver = giver;

    % if there is flux order check that is consistent
    if ~isfield(p.cCycleBase,'fluxOrder')
        p.cCycleBase.fluxOrder = 1:numel(taker);
    else
        if numel(p.cCycleBase.fluxOrder) ~= numel(taker)
            error(['ERR : cFlowAct_gsi : '...
                'numel(p.cCycleBase.fluxOrder) ~= numel(taker)'])
        end
    end

end %function
