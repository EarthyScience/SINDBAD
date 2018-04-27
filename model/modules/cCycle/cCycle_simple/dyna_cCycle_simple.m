function [f,fe,fx,s,d,p] = dyna_cCycle_simple(f,fe,fx,s,d,p,info,tix)
% cycle carbon amongs pools...

% these all need to be zeros... maybe is taken care automatically...

s.cd.cEcoInflux                 =   info.tem.helpers.arrays.zerospixzix.c.cEco;
s.cd.cEcoFlow                   =   info.tem.helpers.arrays.zerospixzix.c.cEco;
% distribute the NPP to the veg pools
zix                             =   info.tem.model.variables.states.c.zix.cEco; %sujan for zix, ask nuno if this is right
s.cd.cNPP                       =   fx.gpp(:,tix) .* s.cd.cAlloc(:,zix) - s.cd.cEcoEfflux(:,zix);
s.cd.cEcoInflux(:,zix)          =   s.cd.cNPP;
% output fluxes
s.cd.cEcoOut                    =   s.prev.s_c_cEco .* s.cd.p_cTauAct_k;
% s.cd.cEcoOut            = s.prev.cEco .* s.cd.p_cTauAct_k;
% circulate carbon within cEco pools
for jix = 1:numel(p.cCycleBase.fluxOrder)
    taker                       = s.cd.p_cFlowAct_taker(p.cCycleBase.fluxOrder(jix));
    giver                       = s.cd.p_cFlowAct_giver(p.cCycleBase.fluxOrder(jix));
    s.cd.cEcoFlow(:,taker)      = s.cd.cEcoFlow(:,taker)   + s.cd.cEcoOut(:,giver) .* s.cd.p_cFlowAct_cTransfer(taker,giver);
    s.cd.cEcoEfflux(:,giver)	= s.cd.cEcoEfflux(:,giver) + s.cd.cEcoOut(:,giver) .* (1 - s.cd.p_cFlowAct_cTransfer(taker,giver));
end
% pools = previous + gains - losses
s.c.cEco                        = s.c.cEco + s.cd.cEcoInflux - s.cd.cEcoOut + s.cd.cEcoFlow;
% s.prev.cEco = s.c.cEco;
% compute RA and RH
fx.cRH(:,tix)                   = sum(s.cd.cEcoEfflux(:,~info.tem.model.variables.states.c.flags.cVeg),2); %sujan added 2 to sum along depth
fx.cRA(:,tix)                   = sum(s.cd.cEcoEfflux(:,info.tem.model.variables.states.c.flags.cVeg),2); %sujan added 2 to sum along depth
fx.cRECO(:,tix)                 = fx.cRH(:,tix) + fx.cRA(:,tix);
fx.cNPP(:,tix)                  = sum(s.cd.cNPP,2);
end % function