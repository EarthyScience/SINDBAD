function [f,fe,fx,s,d,p] = dyna_cCycle_CASA(f,fe,fx,s,d,p,info,tix)
% cycle carbon amongs pools...

% Simple but Update Pools In Cycle (SUPIC)

% these all need to be zeros... maybe is taken care automatically...
s.cd.cEcoInflux                 =   info.tem.helpers.arrays.zerospixzix.c.cEco;
s.cd.cEcoFlow                   =   info.tem.helpers.arrays.zerospixzix.c.cEco;

%% vegetation
zix                     =   info.tem.model.variables.states.c.flags.cVeg; 
% DISTRIBUTE THE NPP TO VEGETATION POOLS
s.cd.cNPP               =   fx.gpp(:,tix) .* s.cd.cAlloc(:,zix) - s.cd.cEcoEfflux(:,zix);
s.cd.cEcoInflux(:,zix)	=   s.cd.cNPP;
s.c.cEco(:,zix)         =   s.c.cEco(:,zix) + s.cd.cEcoInflux(:,zix);

% CALCULATE FOLIAGE AND ROOT CARBON LOST AS LITTER AND DECREMENT PLANT CARBON POOLS
s.cd.cEcoOut(:,zix)     =   min(s.c.cEco(:,zix),s.c.cEco(:,zix) .* s.cd.p_cTauAct_k(:,zix));
s.c.cEco(:,zix)         =   s.c.cEco(:,zix) - s.cd.cEcoOut(:,zix);

%% litter pools
zix                     =   info.tem.model.variables.states.c.zix.cLit;
% INCREMENT LITTER POOLS
for taker = zix
    tndx = find(s.cd.p_cFlowAct_taker == taker);
    for jix = 1:numel(tndx)
        giver                   =   s.cd.p_cFlowAct_giver(tndx(jix));
        s.cd.cEcoFlow(:,taker)  =   s.cd.cEcoFlow(:,taker)   + s.cd.cEcoOut(:,giver) .* s.cd.p_cFlowAct_cTransfer(:,taker,giver);
    end
end
s.c.cEco(:,zix)     =   s.c.cEco(:,zix) + s.cd.cEcoFlow(:,zix);
%% soil flows
% DETERMINE MAXIMUM OUT FLUXES FROM EACH SOIL CARBON POOL
zix                 =   ~info.tem.model.variables.states.c.flags.cVeg; 
s.cd.cEcoOut(:,zix)	=   min(s.c.cEco(:,zix),s.c.cEco(:,zix) .* s.cd.p_cTauAct_k(:,zix));
s.c.cEco(:,zix)     =   s.c.cEco(:,zix) - s.cd.cEcoOut(:,zix);

% COMPUTE CARBON FLUXES IN THE SOIL
flux_order  = [9 8 11 2 1 12 4 3 6 5 16 15 7 14 13 10];
new_flux_order = [];
for jix = 1:numel(p.cCycleBase.fluxOrder)
    taker                       = s.cd.p_cFlowAct_taker(p.cCycleBase.fluxOrder(jix));
    giver                       = s.cd.p_cFlowAct_giver(p.cCycleBase.fluxOrder(jix));
    if sum(giver==info.tem.model.variables.states.c.zix.cVeg)>0,continue,end
    s.cd.cEcoFlow(:,taker)      = s.cd.cEcoFlow(:,taker)   + s.cd.cEcoOut(:,giver) .* s.cd.p_cFlowAct_cTransfer(:,taker,giver);
    s.cd.cEcoEfflux(:,giver)	= s.cd.cEcoEfflux(:,giver) + s.cd.cEcoOut(:,giver) .* (1 - s.cd.p_cFlowAct_cTransfer(:,taker,giver));
new_flux_order = [new_flux_order jix];
end
s.c.cEco(:,zix) = s.c.cEco(:,zix) + s.cd.cEcoFlow(:,zix);

% compute RA and RH
fx.cRH(:,tix)                   = sum(s.cd.cEcoEfflux(:,~info.tem.model.variables.states.c.flags.cVeg),2); %sujan added 2 to sum along depth
fx.cRA(:,tix)                   = sum(s.cd.cEcoEfflux(:,info.tem.model.variables.states.c.flags.cVeg),2); %sujan added 2 to sum along depth
fx.cRECO(:,tix)                 = fx.cRH(:,tix) + fx.cRA(:,tix);
fx.cNPP(:,tix)                  = sum(s.cd.cNPP,2);
end % function