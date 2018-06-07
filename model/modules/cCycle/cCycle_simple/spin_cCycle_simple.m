function [f,fe,fx,s,d,p] = spin_cCycle_simple(f,fe,fx,s,d,p,info,NI2E)
tstart = tic;
% old CASA_fast imported
% NI2E - number of iterations to equilibrium
%{
% NEEDS 
WE NEED TESTS ON EQUILIBRIUM SIMULATIONS... EMPIRICAL VERSUS ANALYTICAL

TSPY - or should be the length of the forcing...
fe.CCycle.DecayRate - AS LONG AS THE TIMESERIES OF npp
%}
% #########################################################################

% the input datasets [f,fe,fx,s,d] have to have a full year (or cycle of
% years) that will be used as the recycling dataset for the determination
% of C pools at equilibrium

% START fCt - final time series of pools
fCt	= d.storedStates.cEco;
sCt = s.c.cEco;

% updated states / diagnostics and fluxes...
sT  = s;
dT  = d;
fxT = fx;

% helpers
nPix    = info.tem.helpers.sizes.nPix;
nTix    = info.tem.helpers.sizes.nTix;
nZix    = info.tem.model.variables.states.c.nZix.cEco;

% matrices for the calculations
cLossRate       = zeros(nPix,nZix,nTix);
cGain           = cLossRate;
cLoxxRate       = cLossRate; % extra losses for vegetation pools...
cFlowRateTrace	= zeros(nPix,nZix,nZix,nTix);

% ORDER OF CALCULATIONS (1 to the end of pools...)
zixVec   = 1:size(s.c.cEco,2);
% SOLVE FOR EQUILIBRIUM
for zix = zixVec
    % general k loss
    cLossRate(:,zix,:) 	= max(min(d.storedStates.p_cTauAct_k(:,zix,:),1),0);
    
    if any(zix==info.tem.model.variables.states.c.zix.cVeg)
        % additional losses (RA) in veg pools
        cLoxxRate(:,zix,:)	= min(1-d.storedStates.p_RAact_km4su(:,zix,:),1);
        % gains in veg pools
        gppShp           = reshape(fx.gpp,nPix,1,nTix); % could be fxT?
        cGain(:,zix,:)	= d.storedStates.cAlloc(:,zix,:) .* gppShp .* p.RAact.YG;
    else
        % no additional gains from outside
        cLoxxRate(:,zix,:)	= 1;
        % losses rates of carbon to other soil pools
        ndxLooseTo = find(s.cd.p_cFlowAct_giver == zix);
        adjustLoss = 0;
        for ii = 1:numel(ndxLooseTo)
            taker                           = s.cd.p_cFlowAct_taker(ndxLooseTo(ii));
            giver                           = s.cd.p_cFlowAct_giver(ndxLooseTo(ii));
            cLossRateShp                    = reshape(cLossRate(:,giver,:),nPix,1,1,nTix);
            cTransferShp                    = reshape(d.storedStates.p_cFlowAct_cTransfer(:,taker,giver,:),nPix,1,nTix);
            cFlowRateTrace(:,taker,giver,:) = cLossRateShp .* d.storedStates.p_cFlowAct_cTransfer(:,taker,giver,:);
            adjustLoss                      = adjustLoss + cTransferShp;
        end
%         cLossRate(:,zix,:) = cLossRate(:,zix,:) .* adjustLoss; % original
%         was uncommented
        % NC : if this pool receive c from a pool that is also fed by it
        
        % gains from other carbon pools
        ndxGainFrom	= find(s.cd.p_cFlowAct_taker == zix);
        for ii = 1:numel(ndxGainFrom)
            taker               = s.cd.p_cFlowAct_taker(ndxGainFrom(ii));
            giver               = s.cd.p_cFlowAct_giver(ndxGainFrom(ii));
            % if the giver was also a taker (loop)
            if any(giver == s.cd.p_cFlowAct_giver(ndxLooseTo))
                cTransferShp        = reshape(d.storedStates.p_cFlowAct_cTransfer(:,taker,giver,:),nPix,1,nTix);
                cFlowRateTraceShp	= reshape(cFlowRateTrace(:,taker,giver,:),nPix,1,nTix);
                cGain(:,taker,:)    = cGain(:,taker,:) + fCt(:,giver,:) .* cFlowRateTraceShp .* cTransferShp;
            else
%                 cGain(:,taker,:)    = cGain(:,taker,:) + (fCt(:,giver,:) ./ (1 - cLossRate(:,giver,:))) .* cLossRate(:,giver,:);
                cGain(:,taker,:)    = cGain(:,taker,:) + (fCt(:,giver,:)) .* cLossRate(:,giver,:);
            end
        end
    end
            
%%  % GET THE POOLS GAINS (Gt) AND LOSSES (Lt)
    % CALCULATE At = 1 - Lt
    At	= squeeze((1 - cLossRate(:,zix,:)) .* cLoxxRate(:,zix,:));
    % calculate Bt
    Bt  = squeeze(cGain(:,zix,:)) .* At;
    % CARBON AT THE END FOR THE FIRST SPINUP PHASE, NPP IN EQUILIBRIUM
    Co	= s.c.cEco(:,zix);%    d.storedStates.cEco(:,zix,:);
    
    % THE NEXT LINES REPRESENT THE ANALYTICAL SOLUTION FOR THE SPIN UP;
    % EXCEPT FOR THE LAST 3 POOLS: SOIL MICROBIAL, SLOW AND OLD. IN THIS
    % CASE SIGNIFICANT APPROXIMATION IS CALCULATED (CHECK NOTEBOOKS).
    piA1        = (prod(At,2)) .^ (NI2E);
    At2         = [At ones(size(At,1),1)];
    sumB_piA    = NaN(size(f.Tair));
    for ii = 1:info.tem.helpers.sizes.nTix
        sumB_piA(:,ii) = Bt(:,ii) .* prod(At2(:,ii+1:info.tem.helpers.sizes.nTix+1),2);
    end
    sumB_piA    = sum(sumB_piA,2);
    T2          = 0:1:NI2E - 1;
    piA2        = (prod(At,2)*ones(1,numel(T2))).^(ones(size(At,1),1)*T2);
    piA2        = sum(piA2, 2);
    
    % FINAL CARBON AT POOL zix
    Ct                      = Co .* piA1 + sumB_piA .* piA2;
    sCt(:,zix) = Ct;
disp(['DBG : Co : ' num2str(zix) ' : ' num2str(Co(1))])
disp(['DBG : Ct : ' num2str(zix) ' : ' num2str(Ct(1))])
%     dT.storedStates.cEco(:,zix,end)	= Ct;
    sT.c.cEco(:,zix)        = Ct;%                 = d.storedStates.cEco;
    sT.prev.s_c_cEco(:,zix)	= Ct;
    
    % CREATE A YEARLY TIME SERIES OF THE POOLS EXCHANGE TO USE IN THE NEXT
    % POOLS CALCULATIONS
    [~,~,fxT,sT,dT] = runCoreTEM(f,fe,fxT,sT,dT,p,info,false,true,false);
    % FEED fCt
    fCt(:,zix,:)	= dT.storedStates.cEco(:,zix,:);
end
% make the fx consistent with the pools
sT.c.cEco = sCt;
sT.prev.s_c_cEco	= sCt;
[f,fe,fx,s,d,p] = runCoreTEM(f,fe,fxT,sT,dT,p,info,false,true,false);

disp(['    TIM : spin_cCycle_simple : end : inputs : ' num2str(NI2E,'%1.0f|') ' : time : ' sec2som(toc(tstart))])


end % function