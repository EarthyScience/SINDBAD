function [f,fe,fx,s,d,p] = dyna_cCycle_simple(f,fe,fx,s,d,p,info,tix)
% cycle carbon amongs pools...

% these all need to be zeros... maybe is taken care automatically...
s.cd.cEcoInflux = zeros(nPix,nZix);
s.cd.cEcoFlow   = zeros(nPix,nZix);
% distribute the NPP to the veg pools
zix                     = info.tem.model.variables.states.c.cVeg.zix;
s.cd.cEcoInflux(:,zix)	= s.cd.cNPP(:,zix);
% output fluxes
s.cd.cEcoOut            = s.prev.cEco .* p.cTauAct.k;
% circulate carbon within cEco pools
for jix = 1:numel(p.cFlowAct.fluxOrder)
    taker                       = p.cFlowAct.taker(p.cCycle.fluxOrder(jix));
    giver                       = p.cFlowAct.giver(p.cCycle.fluxOrder(jix));
    s.cd.cEcoFlow(:,taker)      = s.cd.cEcoFlow(:,taker)   + s.cd.cEcoOut(:,giver) .* p.cFlowAct.cTransfer(taker,giver);
    s.cd.cEcoEfflux(:,giver)	= s.cd.cEcoEfflux(:,giver) + s.cd.cEcoOut(:,giver) .* (1 - p.cFlowAct.cTransfer(taker,giver));
end
% pools = previous + gains - losses
s.c.cEco = s.prev.cEco + s.cd.cEcoInflux - s.cd.cEcoOut + s.cd.cEcoFlow;
% compute RA and RH
fx.cRH = sum(s.cd.cEcoEfflux(:,~info.tem.model.variables.states.c.cVeg.flag));
fx.cRA = sum(s.cd.cEcoEfflux(:,info.tem.model.variables.states.c.cVeg.flag));

end % function