function [f,fe,fx,s,d,p] = dyna_cCycle_simple(f,fe,fx,s,d,p,info,tix)
% cycle carbon between pools...
%% these all need to be zeros... maybe is taken care automatically...
s.cd.cEcoInflux                 =   info.tem.helpers.arrays.zerospixzix.c.cEco;
s.cd.cEcoFlow                   =   info.tem.helpers.arrays.zerospixzix.c.cEco;
%% compute losses
s.cd.cEcoOut	=   min(s.c.cEco,s.c.cEco .* s.cd.p_cTauAct_k);
%% gains to vegetation
zix                     =   info.tem.model.variables.states.c.flags.cVeg; 
s.cd.cNPP               =   fx.gpp(:,tix) .* s.cd.cAlloc(:,zix) - s.cd.cEcoEfflux(:,zix);
s.cd.cEcoInflux(:,zix)          =   s.cd.cNPP;
%% flows and losses
% @nc, if flux order does not matter, remove...
for jix = 1:numel(p.cCycleBase.fluxOrder)
    taker                       = s.cd.p_cFlowAct_taker(p.cCycleBase.fluxOrder(jix));
    giver                       = s.cd.p_cFlowAct_giver(p.cCycleBase.fluxOrder(jix));
    s.cd.cEcoFlow(:,taker)      = s.cd.cEcoFlow(:,taker)   + s.cd.cEcoOut(:,giver) .* s.cd.p_cFlowAct_A(:,taker,giver);
end
%% balance
prevcEco 		= s.c.cEco;
s.c.cEco 	= s.c.cEco + s.cd.cEcoFlow + s.cd.cEcoInflux - s.cd.cEcoOut;
%% compute RA and RH
fx.cNPP(:,tix)                  = sum(s.cd.cNPP,2);
backNEP		    = sum(s.c.cEco,2) - sum(prevcEco,2);
fx.cRA(:,tix)   = fx.gpp(:,tix) - fx.cNPP(:,tix);
fx.cRECO(:,tix) = fx.gpp(:,tix) - backNEP;
fx.cRH(:,tix)   = fx.cRECO(:,tix) - fx.cRA(:,tix);
end % function