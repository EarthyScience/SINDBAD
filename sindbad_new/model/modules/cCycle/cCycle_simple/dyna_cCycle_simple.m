function [f,fe,fx,s,d,p] = dyna_cCycle_CASA(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% FUNCTION	: dyna_cCycle_CASA
% 
% PURPOSE	: 
% 
% REFERENCES:
% Potter, C. S., J. T. Randerson, C. B. Field, P. A. Matson, P. M.
% Vitousek, H. A. Mooney, and S. A. Klooster. 1993.  Terrestrial ecosystem
% production: A process model based on global satellite and surface data. 
% Global Biogeochemical Cycles. 7: 811-841. 
% 
% CONTACT	: Nuno
% 
% INPUT
% fe.cCycle.MTF
% fe.cTaufwSoil.BGME
% s.cd.cAlloc(:,zix)
% s.c.cEco(:,zix)
% fe.cCycle.DecayRate(ii).value
% fe.cCycle.ctransfer
% 
% OUTPUT
% s.c.cEco
% fx.efflux
% 
% #########################################################################

% loop to get inputs and outputs...
for zix = info.tem.model.variables.states.c.cEco.zix
    s.c.cEco(:,zix)	= s.c.cEco(:,zix) + s.cd.cNPP(:,zix) - ...
        ;
end




% ALLOCATION NPP TO pvegETATION POOLS
for zix = info.tem.model.variables.states.c.cVeg.zix
    s.c.cEco(:,zix)	= s.c.cEco(:,zix) + s.cd.cNPP(:,zix);
end

% CALCULATE FOLIAGE AND ROOT CARBON LOST AS LITTER AND DECREMENT PLANT
% CARBON POOLS
for zix = info.tem.model.variables.states.c.cSoil.zix
    s.cd.cOutPot(:,zix)  = min(s.c.cEco(:,zix),s.c.cEco(:,zix) .* fe.cCycle.DecayRate(zix).value(:,tix));
    s.c.cEco(:,zix)	= s.c.cEco(:,zix) - s.cd.cOutPot(:,zix);
end

%% check this shit
% INCREMENT LITTER CARBON POOLS - out of leafs
s.c.cEco(:,5)	= s.c.cEco(:,5) + s.cd.cOutPot(:,4) .* MTF;
s.c.cEco(:,6)	= s.c.cEco(:,6) + s.cd.cOutPot(:,4) .* (1 - MTF);

% INCREMENT LITTER CARBON POOLS - out of wood
s.c.cEco(:,9)	= s.c.cEco(:,9) + s.cd.cOutPot(:,3);

% INCREMENT LITTER CARBON POOLS - out of roots
s.c.cEco(:,7)   = s.c.cEco(:,7) + s.cd.cOutPot(:,1) .* MTF;
s.c.cEco(:,8)   = s.c.cEco(:,8) + s.cd.cOutPot(:,1) .* (1 - MTF);
s.c.cEco(:,10)	= s.c.cEco(:,10) + s.cd.cOutPot(:,2);
%%

% DETERMINE MAXIMUM FLUXES FROM EACH CARBON POOL
for zix = info.tem.model.variables.states.c.cSoil.zix
    s.cd.cOutPot(:,zix)   = min(s.c.cEco(:,zix), s.c.cEco(:,zix) .* fe.cCycle.kfEnvTs(zix).value(:,tix) .* BGME);
    % make sure the soil respiratory fluxes are 0
	s.cd.cEcoEfflux(:,zix)	= 0;
end

% COMPUTE CARBON FLUXES IN THE psoil
flux_order  = [9 8 11 2 1 12 4 3 6 5 16 15 7 14 13 10];
for ij = 1:numel(flux_order)
    zix                              = flux_order(ij); % this saves, like, 1/3 of the time in the function...
    idonor                          = fe.cCycle.ctransfer(zix).donor;
    ireceiver                       = fe.cCycle.ctransfer(zix).receiver;
    cOUT                            = s.cd.cOutPot(:,idonor) .* fe.cCycle.ctransfer(zix).xtrEFF;
    s.c.cEco(:,idonor)          = s.c.cEco(:,idonor)    - cOUT;
    s.c.cEco(:,ireceiver)       = s.c.cEco(:,ireceiver) + cOUT .* fe.cCycle.ctransfer(zix).effFLUX;
    
    s.cd.cEcoEfflux(:,idonor)   = s.cd.cEcoEfflux(:,idonor)+ cOUT .* (1 - fe.cCycle.ctransfer(zix).effFLUX);
    
end

% feed the rh fluxes
fx.rh(:,tix)  = 0;
for zix = 5:14
	fx.rh(:,tix)	= fx.rh(:,tix) + s.cd.cEcoEfflux(:,zix);
end

end % function
