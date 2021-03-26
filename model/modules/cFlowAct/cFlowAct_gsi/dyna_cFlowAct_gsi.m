function [f, fe, fx, s, d, p] = dyna_cFlowAct_gsi(f, fe, fx, s, d, p, info, tix)
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
    %   - p.cFlowAct.LR2ReSlp:         slope from leaf/root to reserve
    %   - p.cFlowAct.Re2LRSlp:         slope from reserve to leaf/roots
    %   - p.cFlowAct.kShed:            carbon allocation to litter from shedding
    %
    % Outputs:
    %   - s.cd.p_cFlowAct_A:            updated transfer flow rate for carbon at ecosystem level
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
    % Notes:
    % currently not needed to check the growth but the code may be implemented in future
    % cVegZix = info.tem.model.variables.states.c.zix.cVeg;
    % d.cFlowAct.cVegTotal(:,tix) = sum(s.c.cEco(:,cVegZix),2);
    % s_cur = s.c.cEco + s.cd.del_cEco; % need this trick becuase s.cd.del_cEco (increase of stock in the previous time step) only has a nZix of 1 in the first time step
    % s_del = s_cur - s.c.cEco;
    % cVeg_growth = sum(s_del(:,cVegZix),2);
    % d.cFlowAct.cVeg_growth(:,tix)=cVeg_growth;
    % d.cFlowAct.L2ReCG(:,tix)                          =  min(max(-d.cFlowAct.slope_fWfTfR(:,tix),0) .* p.cFlowAct.LR2ReSlp ,1) .* (cVeg_growth < 0);
    %
    % Versions:
    %   - 1.0 on 13.01.2020 (sbesnard)
    %   - 1.1 on 05.02.2021 (skoirala): changes with stressors and smoothing as well as handling the activation of leaf/root to reserve or reserve to leaf/root switches. Adjustment of total flow rates (cTau) of relevant pools
    %
    % +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    % Compute sigmoid functions
    % LPJ-GSI formulation: In GSI, the stressors are smoothened per control variable. That means, gppfwSoil, fTair, and fRdiff should all have a GSI approach for 1:1 conversion. For now, the function below smoothens the combined stressors, and then calculates the slope for allocation

    % current time step before smoothing
    f_tmp = d.cAllocfwSoil.fW(:, tix) .* d.cAllocfTsoil.fT(:, tix) .* d.cAllocfRad.fR(:, tix);

    % stressor from previos time step
    f_prev = d.prev.d_cFlowAct_fWfTfR;

    % get the smoothened stressor based on contribution of previous steps using ARMA-like formulation
    f_now = (1 - p.cFlowAct.f_tau) .* f_prev + p.cFlowAct.f_tau .* f_tmp;

    d.cFlowAct.fWfTfR(:, tix) = f_now;
    d.cFlowAct.slope_fWfTfR(:, tix) = f_now -f_prev;

    % get the indices of leaf and root
    cVegLeafzix = info.tem.model.variables.states.c.zix.cVegLeaf;
    cVegRootzix = info.tem.model.variables.states.c.zix.cVegRoot;
    cVegReservezix = info.tem.model.variables.states.c.zix.cVegReserve;

    % calculate the flow rate for exchange with reserve pools based on the slopes
    % get the flow and shedding rates
    LR2Re = min(max(-d.cFlowAct.slope_fWfTfR(:, tix), 0) .* p.cFlowAct.LR2ReSlp, 1); % .* (cVeg_growth < 0);
    Re2LR = min(max(d.cFlowAct.slope_fWfTfR(:, tix), 0) .* p.cFlowAct.Re2LRSlp, 1); %.* (cVeg_growth > 0);
    KShed = min(max(-d.cFlowAct.slope_fWfTfR(:, tix), 0) .* p.cFlowAct.kShed, 1);

    % set the Leaf and Root to Reserve flow rate as the same
    L2Re = LR2Re; % should it be divided by 2?
    R2Re = LR2Re;

    k_Lshed = KShed;
    k_Rshed = KShed;

    % Estimate flows from reserve to leaf and root
    Re2L = Re2LR .* (d.cAllocfwSoil.fW(:, tix) ./ (d.cAllocfRad.fR(:, tix) + d.cAllocfwSoil.fW(:, tix))); % if water stressor is high (=low water stress), larger fraction of reserve goes to the leaves for light acquisition
    Re2R = Re2LR .* (d.cAllocfRad.fR(:, tix) ./ (d.cAllocfRad.fR(:, tix) + d.cAllocfwSoil.fW(:, tix))); % if light stressor is high (=sufficient light), larger fraction of reserve goes to the root for water uptake

    % the following two lines lead to k larger than 1, which results in negative carbon pools.
    % s.cd.p_cTauAct_k(:,cVegLeafzix)    = s.cd.p_cTauAct_k(:,cVegLeafzix) + d.cFlowAct.k_Lshed(:,tix) + d.cFlowAct.L2Re(:,tix);
    % s.cd.p_cTauAct_k(:,cVegRootzix)    = s.cd.p_cTauAct_k(:,cVegRootzix) + d.cFlowAct.k_Rshed(:,tix) + d.cFlowAct.R2Re(:,tix);

    % adjust the outflow rate from the flow pools
    s.cd.p_cTauAct_k(:, cVegLeafzix) = min((s.cd.p_cTauAct_k(:, cVegLeafzix) + k_Lshed + L2Re), 1);
    L2ReF = L2Re ./ (s.cd.p_cTauAct_k(:, cVegLeafzix));
    k_LshedF = k_Lshed ./ (s.cd.p_cTauAct_k(:, cVegLeafzix));

    s.cd.p_cTauAct_k(:, cVegRootzix) = min((s.cd.p_cTauAct_k(:, cVegRootzix) + k_Rshed + R2Re), 1);
    R2ReF = R2Re ./ (s.cd.p_cTauAct_k(:, cVegRootzix));
    k_RshedF = k_Rshed ./ (s.cd.p_cTauAct_k(:, cVegRootzix));

    s.cd.p_cTauAct_k(:, cVegReservezix) = min((s.cd.p_cTauAct_k(:, cVegReservezix) + Re2L + Re2R), 1);
    Re2LF = Re2L ./ s.cd.p_cTauAct_k(:, cVegReservezix);
    Re2RF = Re2R ./ s.cd.p_cTauAct_k(:, cVegReservezix);

    % Adjust cFlow between reserve, leaf, root, and soil
    % Adjust cFlow between reserve, leaf, root, and soil
    % s.cd.p_cFlowAct_aM{1} = Re2L;
    % s.cd.p_cFlowAct_aM{2} = Re2R;
    % s.cd.p_cFlowAct_aM{3} = L2ReF;
    % s.cd.p_cFlowAct_aM{4} = R2ReF;
    % s.cd.p_cFlowAct_aM{5} = k_LshedF;
    % s.cd.p_cFlowAct_aM{6} = k_RshedF;


    % while using the indexing of aM would be elegant, the speed is really slow, and hence the following block of code is implemented
    for ii = 1:size(s.cd.p_cFlowAct_ndxSrc, 1)
        ndxSrc = s.cd.p_cFlowAct_ndxSrc(ii);
        ndxTrg = s.cd.p_cFlowAct_ndxTrg(ii);

        if ii == 1
            s.cd.p_cFlowAct_A(:, ndxTrg, ndxSrc) = Re2LF;
        elseif ii == 2
            s.cd.p_cFlowAct_A(:, ndxTrg, ndxSrc) = Re2RF;
        elseif ii == 3
            s.cd.p_cFlowAct_A(:, ndxTrg, ndxSrc) = L2ReF;
        elseif ii == 4
            s.cd.p_cFlowAct_A(:, ndxTrg, ndxSrc) = R2ReF;
        elseif ii == 5
            s.cd.p_cFlowAct_A(:, ndxTrg, ndxSrc) = k_LshedF;
        elseif ii == 6
            s.cd.p_cFlowAct_A(:, ndxTrg, ndxSrc) = k_RshedF;
        end

    end

    % store the varibles in diagnostic structure
    d.cFlowAct.L2Re(:, tix) = LR2Re; % should it be divided by 2?
    d.cFlowAct.R2Re(:, tix) = R2Re;

    d.cFlowAct.k_Lshed(:, tix) = KShed;
    d.cFlowAct.k_Rshed(:, tix) = KShed;

    d.cFlowAct.Re2L(:, tix) = Re2LF;
    d.cFlowAct.Re2R(:, tix) = Re2RF;

    d.cFlowAct.L2ReF(:, tix) = L2ReF; % should it be divided by 2?
    d.cFlowAct.R2ReF(:, tix) = R2ReF;

    d.cFlowAct.k_LshedF(:, tix) = k_LshedF;
    d.cFlowAct.k_RshedF(:, tix) = k_RshedF;

end %function
