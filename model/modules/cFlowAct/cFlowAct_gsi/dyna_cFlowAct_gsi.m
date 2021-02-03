function [f,fe,fx,s,d,p] = dyna_cFlowAct_gsi(f,fe,fx,s,d,p,info,tix)
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

    % a ARMA smoothing function for stressors
    f_smooth  = @(f_p,f_n,tau)(1-tau) .* f_p + tau .* f_n;
    % current time step before smoothing
    f_tmp = d.cAllocfwSoil.fW(:, tix) .* d.cAllocfTsoil.fT(:, tix) .* d.cAllocfRad.fR(:, tix);


    % stressor from previos time step
    f_prev = d.prev.d_cFlowAct_fWfTfR;
    f_now  = f_smooth(f_prev, f_tmp, p.cFlowAct.f_tau);

    d.cFlowAct.fWfTfR(:,tix) = f_now;
    d.cFlowAct.slope_fWfTfR(:,tix) = f_now -f_prev;


    % calculate the flow rate for exchange with reserve pools based on the slopes

    % get the flow and shedding rates
    LR2Re                          =  min(max(-d.cFlowAct.slope_fWfTfR(:,tix),0) .* p.cFlowAct.LR2ReSlp ,1);% .* (cVeg_growth < 0);
    Re2LR                          =  min(max(d.cFlowAct.slope_fWfTfR(:,tix),0) .* p.cFlowAct.Re2LRSlp ,1);%.* (cVeg_growth > 0);
    KShed                          =  min(max(-d.cFlowAct.slope_fWfTfR(:,tix),0) .* p.cFlowAct.kShed ,1);

    % set the Leaf and Root to Reserve flow rate as the same
    d.cFlowAct.L2Re(:,tix)         =  LR2Re; % should it be divided by 2?
    d.cFlowAct.R2Re(:,tix)         =  LR2Re;

    d.cFlowAct.k_Lshed(:,tix)      =  KShed;
    d.cFlowAct.k_Rshed(:,tix)      =  KShed;

    % Estimate flows from reserve to leaf and root
    d.cFlowAct.Re2L(:,tix)         =  Re2LR .* (d.cAllocfwSoil.fW(:, tix) ./ (d.cAllocfRad.fR(:, tix) + d.cAllocfwSoil.fW(:, tix))); % if water stressor is high (=low water stress), larger fraction of reserve goes to the leaves for light acquisition
    d.cFlowAct.Re2R(:,tix)         =  Re2LR .* (d.cAllocfRad.fR(:, tix)   ./ (d.cAllocfRad.fR(:, tix) + d.cAllocfwSoil.fW(:, tix))); % if light stressor is high (=sufficient light), larger fraction of reserve goes to the root for water uptake

    % Update k leaf, root including the flows to reserve and shedding
    cVegLeafzix                        = info.tem.model.variables.states.c.zix.cVegLeaf;
    s.cd.p_cTauAct_k(:,cVegLeafzix)    = s.cd.p_cTauAct_k(:,cVegLeafzix) + d.cFlowAct.k_Lshed(:,tix) + d.cFlowAct.L2Re(:,tix);
    cVegRootzix                        = info.tem.model.variables.states.c.zix.cVegRoot;
    s.cd.p_cTauAct_k(:,cVegRootzix)    = s.cd.p_cTauAct_k(:,cVegRootzix) + d.cFlowAct.k_Rshed(:,tix) + d.cFlowAct.R2Re(:,tix);



    d.cFlowAct.L2ReF(:,tix)         =  d.cFlowAct.L2Re(:,tix) ./ (s.cd.p_cTauAct_k(:,cVegLeafzix)); % should it be divided by 2?
    d.cFlowAct.R2ReF(:,tix)         =  d.cFlowAct.R2Re(:,tix) ./ (s.cd.p_cTauAct_k(:,cVegRootzix));

    % Adjust cFlow between reserve, leaf, root, and soil
    aM = {...
        'cVegReserve',  'cVegLeaf',    d.cFlowAct.Re2L(:,tix); ...
        'cVegReserve',  'cVegRoot',    d.cFlowAct.Re2R(:,tix); ...
        'cVegLeaf',     'cVegReserve', d.cFlowAct.L2ReF(:,tix); ...
        'cVegRoot',     'cVegReserve', d.cFlowAct.R2ReF(:,tix); ...
        'cVegLeaf',     'cSoil',       1 - d.cFlowAct.L2ReF(:,tix); ... 
        'cVegRoot',     'cSoil',       1 - d.cFlowAct.R2ReF(:,tix); ... 
        };


    for ii = 1:size(aM, 1)
        ndxSrc = info.tem.model.variables.states.c.zix.(aM{ii, 1});
        ndxTrg = info.tem.model.variables.states.c.zix.(aM{ii, 2}); 

        for iSrc = 1:numel(ndxSrc)

            for iTrg = 1:numel(ndxTrg)
                s.cd.p_cFlowAct_A(:, ndxTrg(iTrg), ndxSrc(iSrc)) = aM{ii, 3};
            end
        end
    end

end %function
