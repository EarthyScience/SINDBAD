function [f,fe,fx,s,d,p] = spin_cCycle_CASA(f, fe, fx, s, d, p, info, NI2E)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Solve the steady state of the cCycle for the CASA model based on
% recurrent. Returns the model C pools in equilibrium
%
% Inputs:
%   - fx.gpp:                       values for gross primary productivity
%   - d.storedStates.p_cTauAct_k:   Turn over times carbon pools
%   - s.cd.p_cFlowAct_taker:        taker pool array
%   - s.cd.p_cFlowAct_giver:        giver pool array
%   - s.cd.p_cFlowAct_E:            effect of soil and vegetation on transfer efficiency between pools
%
% Outputs:
%   - sT.c.cEco:   states of the different carbon pools
%
% Modifies:
%   -
%
% References:
% Not published but similar to the following:
%   - Lardy, R., Bellocchi, G., & Soussana, J. F. (2011). A new method to determine soil organic carbon equilibrium.
%     Environmental modelling & software, 26(12), 1759-1763.
%
% Created by:
%   - Nuno Carvalhais (ncarval)
%   - Sujan Koirala (skoirala)
%
% Versions:
%   - 1.0 on 01.05.2018
%   - 1.1 on 29.10.2019: fixed the wrong removal of a dimension by squeeze on
%     Bt and At when nPix == 1 (single point simulation)
%
% Notes:
%   - the input datasets [f,fe,fx,s,d] have to have a full year (or cycle
%   of years) that will be used as the recycling dataset for the
%   determination of C pools at equilibrium
%   - for model structures that loop the carbon cycle between pools this is
%   merely a rough approximation (the solution does not really work...)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

tstart = tic;

% START fCt - final time series of pools
fCt = d.storedStates.cEco;
sCt = s.c.cEco;

% updated states / diagnostics and fluxes...
sT = s;
dT = d;
fxT = fx;

% helpers
nPix = info.tem.helpers.sizes.nPix;
nTix = info.tem.helpers.sizes.nTix;
nZix = info.tem.model.variables.states.c.nZix.cEco;

% matrices for the calculations
cLossRate = zeros(nPix, nZix, nTix);
cGain = cLossRate;
cLoxxRate = cLossRate;

%% some debugging
% if~isfield(d.storedStates,'p_raAct_km4su')
%    d.storedStates.p_raAct_km4su = cLossRate;
% end
% if~isfield(p,'raAct')
%    p.raAct.YG = 1;
% elseif~isfield(p.raAct,'YG')
%    p.raAct.YG = 1;
% end
%% ORDER OF CALCULATIONS (1 to the end of pools...)
zixVec = 1:size(s.c.cEco, 2);
% BUT, we sort from left to right (veg to litter to soil) and prioritize
% without loops
kmoves = 0;
zixVecOrder = zixVec;
zixVecOrder_veg = [];
zixVecOrder_nonVeg = [];
for zix = zixVec
    move = false;
    ndxGainFrom = find(s.cd.p_cFlowAct_taker == zix);
    ndxLoseToZix = s.cd.p_cFlowAct_taker(s.cd.p_cFlowAct_giver == zix);
    
    for ii = 1:numel(ndxGainFrom)
        giver = s.cd.p_cFlowAct_giver(ndxGainFrom(ii));
        
        if any(giver == ndxLoseToZix)
            move = true;
            kmoves = kmoves + 1;
        end
        
    end
    
    if move
        zixVecOrder(zixVecOrder == zix) = [];
        zixVecOrder = [zixVecOrder zix];
    end
    
    
end

for zv = zixVecOrder
    if any(zv == info.tem.model.variables.states.c.zix.cVeg)
        zixVecOrder_veg = [zixVecOrder_veg zv];
    else
        zixVecOrder_nonVeg = [zixVecOrder_nonVeg zv];
    end
end
zixVecOrder = [zixVecOrder_veg zixVecOrder_nonVeg];
%     zixVecOrder = [2 1 3 4 5];
% if kmoves > 0
%     zixVecOrder = [zixVecOrder zixVecOrder(end-kmoves+1:end)];
% end
%% solve it for each pool individually
disp(pad('.', 200, 'both', '.'))
for zix = zixVecOrder
    % general k loss
%     cLossRate(:, zix, :) = max(min(d.storedStates.p_cTauAct_k(:, zix, :), 1), 0);
    cLossRate(:, zix, :) = max(min(d.storedStates.p_cTauAct_k(:, zix, :), 0.9999999), 1e-7); %1 replaced by 0.9999 to avoid having denom in line 140 > 0. 
                                                                                           % so that pools are not NaN
    
    if any(zix == info.tem.model.variables.states.c.zix.cVeg)
        % additional losses (RA) in veg pools
        cLoxxRate(:, zix, :) = min(1 - d.storedStates.p_raAct_km4su(:, zix, :), 1);
        % gains in veg pools
        gppShp = reshape(fx.gpp, nPix, 1, nTix); % could be fxT?
        cGain(:, zix, :) = d.storedStates.cAlloc(:, zix, :) .* gppShp .* p.raAct.YG;
    end
    if any(zix == s.cd.p_cFlowAct_taker)
        % no additional gains from outside
        if ~any(zix == info.tem.model.variables.states.c.zix.cVeg)
            cLoxxRate(:, zix, :) = 1;
        end
        % gains from other carbon pools
        ndxGainFrom = find(s.cd.p_cFlowAct_taker == zix);
        
        for ii = 1:numel(ndxGainFrom)
            taker = s.cd.p_cFlowAct_taker(ndxGainFrom(ii)); % @nc : taker always has to be the same as zix...
            giver = s.cd.p_cFlowAct_giver(ndxGainFrom(ii));
            denom = (1 - cLossRate(:, giver, :));
            adjustGain = d.storedStates.p_cFlowAct_A(:, taker, giver, :);
            adjustGain3D = reshape(adjustGain, nPix, 1, nTix);
            cGain(:, taker, :) = cGain(:, taker, :) + (fCt(:, giver, :) ./ denom) .* cLossRate(:, giver, :) .* adjustGain3D;
        end
        
    end
    
    %% GET THE POOLS GAINS (Gt) AND LOSSES (Lt)
    % CALCULATE At = 1 - Lt
    At = squeeze((1 - cLossRate(:, zix, :)) .* cLoxxRate(:, zix, :));
    %sujan 29.10.2019: the squeeze removes the first dimension while
    %running for a single point when nPix == 1
    if size(cLossRate, 1) == 1
        At = At';
        Bt = squeeze(cGain(:, zix, :))' .* At;
    else
        Bt = squeeze(cGain(:, zix, :)) .* At;
    end
    
    %sujan end squeeze fix
    % CARBON AT THE END FOR THE FIRST SPINUP PHASE, NPP IN EQUILIBRIUM
    Co = s.c.cEco(:, zix);
    % THE NEXT LINES REPRESENT THE ANALYTICAL SOLUTION FOR THE SPIN UP;
    % EXCEPT FOR THE LAST 3 POOLS: SOIL MICROBIAL, SLOW AND OLD. IN THIS
    % CASE SIGNIFICANT APPROXIMATION IS CALCULATED (CHECK NOTEBOOKS).
    piA1 = (prod(At, 2)).^(NI2E);
    At2 = [At ones(size(At, 1), 1)];
    sumB_piA = NaN(size(f.Tair));
    
    for ii = 1:nTix
        sumB_piA(:, ii) = Bt(:, ii) .* prod(At2(:, ii + 1:nTix + 1), 2);
    end
    
    sumB_piA = sum(sumB_piA, 2);
    T2 = 0:1:NI2E - 1;
    piA2 = (prod(At, 2) * ones(1, numel(T2))).^(ones(size(At, 1), 1) * T2);
    piA2 = sum(piA2, 2);
    
    % FINAL CARBON AT POOL zix
    Ct = Co .* piA1 + sumB_piA .* piA2;
    sCt(:, zix) = Ct;
    disp([pad('  cCycle FAST SPINUP', 20) ' : ' pad('spin_cCycle_CASA', 20) ' | : Co : ' num2str(zix) ' : ' num2str(round(Co(1), 2))])
    disp([pad('  cCycle FAST SPINUP', 20) ' : ' pad('spin_cCycle_CASA', 20) ' | : Ct : ' num2str(zix) ' : ' num2str(round(Ct(1), 2))])
    
    sT.c.cEco(:, zix) = Ct;
    sT.prev.s_c_cEco(:, zix) = Ct;
%     if isnan(Ct)
%         kera
%     end
    
    % CREATE A YEARLY TIME SERIES OF THE POOLS EXCHANGE TO USE IN THE NEXT
    % POOLS CALCULATIONS
    [~, ~, fxT, sT, dT] = runCoreTEM(f, fe, fxT, sT, dT, p, info, false, true, false);
    % FEED fCt
    % fCt(:,zix,:)    = dT.storedStates.cEco(:,zix,:);
    fCt = dT.storedStates.cEco;
end

disp(pad('.', 200, 'both', '.'))
% make the fx consistent with the pools
sT.c.cEco = sCt;
sT.prev.s_c_cEco = sCt;
[f, fe, fx, s, d, p] = runCoreTEM(f, fe, fxT, sT, dT, p, info, false, true, false);

disp([pad('TIMERUN FAST SPINUP', 20, 'left') ' : ' pad('spin_cCycle_CASA', 20) ' | inputs : ' num2str(NI2E, '%1.0f |') ', time : ' sec2som(toc(tstart))])
end
