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

    % Compute sigmoid functions
    pcFlowAct_fWfTfR               =  d.prev.d_cAllocfwSoil_fW .* d.prev.d_cAllocfTsoil_fT .* d.prev.d_cAllocfRad_fR;
    d.cFlowAct.fWfTfR(:,tix)       =  d.cAllocfwSoil.fW(:, tix) .* d.cAllocfTsoil.fT(:, tix) .* d.cAllocfRad.fR(:, tix);    
    d.cFlowAct.slope_fWfTfR(:,tix) =  d.cFlowAct.fWfTfR(:,tix) - pcFlowAct_fWfTfR;
    d.cFlowAct.sigGrow(:,tix)      =  1 ./ (1+exp(-30.*d.cFlowAct.slope_fWfTfR(:,tix)));
    d.cFlowAct.sigShed(:,tix)      =  1 ./ (1+exp(30.*d.cFlowAct.slope_fWfTfR(:,tix)));
    d.cFlowAct.sigStore(:,tix)     =  d.cFlowAct.sigShed(:,tix);

    % Estimate flows from reserve to leave and root
    d.cFlowAct.Re2L(:,tix)         = d.cFlowAct.sigGrow(:,tix) .* (d.cAllocfwSoil.fW(:, tix) ./ (d.cAllocfRad.fR(:, tix) + d.cAllocfwSoil.fW(:, tix)));
    d.cFlowAct.Re2R(:,tix)         = d.cFlowAct.sigGrow(:,tix) .* (d.cAllocfRad.fR(:, tix)   ./ (d.cAllocfRad.fR(:, tix) + d.cAllocfwSoil.fW(:, tix)));

    % Esimate k parametets from leaf/root to reserve, leaf to shedding, and retrieve maintenance k
    k_LRe                          = p.cFlowAct.kLRe_base     .* d.cFlowAct.sigStore(:,tix)   .* abs(d.cFlowAct.slope_fWfTfR(:,tix));
    k_RRe                          = p.cFlowAct.kRRe_base     .* d.cFlowAct.sigStore(:,tix)   .* abs(d.cFlowAct.slope_fWfTfR(:,tix));
    k_Lshed                        = p.cFlowAct.kLshed_base   .* d.cFlowAct.sigShed(:,tix)    .* abs(d.cFlowAct.slope_fWfTfR(:,tix));
    k_Rshed                        = p.cFlowAct.kRshed_base   .* d.cFlowAct.sigShed(:,tix)    .* abs(d.cFlowAct.slope_fWfTfR(:,tix));
    
    % Esimate flows from leaf/root to reserve and leaf to shedding
    d.cFlowAct.L2Re(:,tix)         = k_LRe ./ (k_Lshed + k_LRe);
    d.cFlowAct.R2Re(:,tix)         = k_RRe ./ (k_Rshed + k_RRe);

    % Update k leave, root and reserve
    cVegLeafzix                        = info.tem.model.variables.states.c.zix.cVegLeaf;
    s.cd.p_cTauAct_k(:,cVegLeafzix)    = s.cd.p_cTauAct_k(:,cVegLeafzix) + k_Lshed + k_LRe;
    cVegRootzix                        = info.tem.model.variables.states.c.zix.cVegRoot;
    s.cd.p_cTauAct_k(:,cVegRootzix)    = s.cd.p_cTauAct_k(:,cVegRootzix) + k_Rshed + k_RRe;
    %cVegReservezix                     = info.tem.model.variables.states.c.zix.cVegReserve;
    %s.cd.p_cTauAct_k(:,cVegReservezix) = sigGrow*p.cFlowAct.kRe_base;

    % Estimate flows between reserve, leave, root and shed
    %pcFlowAct_fWfTfR = d.prev.d_cAllocfwSoil_fW .* d.prev.d_cAllocfTsoil_fT .* d.prev.d_cAllocfRad_fR;
    %cFlowAct.fWfTfR = d.cAllocfwSoil.fW(:, tix) .* d.cAllocfTsoil.fT(:, tix) .* d.cAllocfRad.fR(:, tix);
    %d.cFlowAct.LR2Re(:,tix) = min(max(pcFlowAct_fWfTfR - cFlowAct.fWfTfR, 0) .* p.cFlowAct.LR2ReSlp, 1); % if DAS degrades, mobilize c to reserves
    %d.cFlowAct.Re2LR(:,tix) = min(max(cFlowAct.fWfTfR - pcFlowAct_fWfTfR, 0) .* p.cFlowAct.Re2LRSlp, 1); % if DAS increases, mobilize c to leafs and roots
    %d.cFlowAct.kShed(:,tix) = min(max(pcFlowAct_fWfTfR - cFlowAct.fWfTfR, 0) .* p.cFlowAct.kShed, 1); % if DAS degrades increase c to litter

    % Do A matrix
    s.cd.p_cFlowAct_A               = repmat(reshape(p.cCycleBase.cFlowA, [1 size(p.cCycleBase.cFlowA)]), info.tem.helpers.sizes.nPix, 1, 1);

    % Adjust cFlow between reserve, leave, root, and soil
    aM = {...
        'cVegReserve',  'cVegLeaf',    d.cFlowAct.Re2L(:,tix); ...
        'cVegReserve',  'cVegRoot',    d.cFlowAct.Re2R(:,tix); ...
        'cVegLeaf',     'cVegReserve', d.cFlowAct.L2Re(:,tix); ...
        'cVegRoot',     'cVegReserve', d.cFlowAct.R2Re(:,tix); ...
        'cVegLeaf',     'cSoil',       1 - d.cFlowAct.L2Re(:,tix); ... 
        'cVegRoot',     'cSoil',       1 - d.cFlowAct.R2Re(:,tix); ... 
        };

    % Adjust cFlow between reserve, leave, root, and soil
    %aM = {...
    %  'cVegReserve',  'cVegLeaf',    d.cFlowAct.Re2LR(:,tix)./2; ...d.cFlowAct.Re2R
    %  'cVegReserve',  'cVegRoot',    d.cFlowAct.Re2LR(:,tix)./2; ...
    %  'cVegLeaf',     'cVegReserve', d.cFlowAct.LR2Re(:,tix)./2; ...
    %  'cVegLeaf',     'cVegReserve', d.cFlowAct.LR2Re(:,tix)./2; ...
    %  'cVegLeaf',     'cSoil',       1 - d.cFlowAct.LR2Re(:,tix)./2; ... 
    %  'cVegRoot',     'cSoil',       1 - d.cFlowAct.R2Re(:,tix); ... 
    %  };
    
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
end %function
