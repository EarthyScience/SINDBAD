function [f,fe,fx,s,d,p] = dyna_cCycle_CASA(f,fe,fx,s,d,p,info,tix)
% cycle carbon between pools...
%% these all need to be zeros... maybe is taken care automatically...
s.cd.cEcoInflux                 =   info.tem.helpers.arrays.zerospixzix.c.cEco;
s.cd.cEcoFlow                   =   info.tem.helpers.arrays.zerospixzix.c.cEco;
s.cd.cEcoEfflux(:,~info.tem.model.variables.states.c.flags.cVeg)   =   0;
%% compute losses
s.cd.cEcoOut	=   minsb(s.c.cEco,s.c.cEco .* s.cd.p_cTauAct_k);
%% gains to vegetation
zix                     =   info.tem.model.variables.states.c.flags.cVeg; 
s.cd.cNPP               =   fx.gpp(:,tix) .* s.cd.cAlloc(:,zix) - s.cd.cEcoEfflux(:,zix);
s.cd.cEcoInflux(:,zix)	=   s.cd.cNPP;
%% flows and losses
% @nc, if flux order does not matter, remove...
for jix = 1:numel(p.cCycleBase.fluxOrder)
    taker                       = s.cd.p_cFlowAct_taker(p.cCycleBase.fluxOrder(jix));
    giver                       = s.cd.p_cFlowAct_giver(p.cCycleBase.fluxOrder(jix));
    out                         = s.cd.cEcoOut(:,giver) .* s.cd.p_cFlowAct_F(:,taker,giver);
    s.cd.cEcoFlow(:,taker)      = s.cd.cEcoFlow(:,taker)   + out .* s.cd.p_cFlowAct_E(:,taker,giver);
    s.cd.cEcoEfflux(:,giver)	= s.cd.cEcoEfflux(:,giver) + out .* (1 - s.cd.p_cFlowAct_E(:,taker,giver));
end
%% balance
s.c.cEco        = s.c.cEco + s.cd.cEcoFlow + s.cd.cEcoInflux - s.cd.cEcoOut;
%% compute RA and RH
fx.cRH(:,tix)                   = sum(s.cd.cEcoEfflux(:,~info.tem.model.variables.states.c.flags.cVeg),2); %sujan added 2 to sum along depth
fx.cRA(:,tix)                   = sum(s.cd.cEcoEfflux(:,info.tem.model.variables.states.c.flags.cVeg),2); %sujan added 2 to sum along depth
fx.cRECO(:,tix)                 = fx.cRH(:,tix) + fx.cRA(:,tix);
fx.cNPP(:,tix)                  = sum(s.cd.cNPP,2);
end % function