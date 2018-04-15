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
% 
% OUTPUT
% s.c.cEco
% fx.efflux
% 
% #########################################################################

% get the photosynthesis inputs into the plant pools






% MAKE SURE THAT THE INTERVALS OF kin (instantaneous turnover rates) ARE OK...
% this shoudl go to the cTauAct
p.cCycle.kin	= max(min(p.cCycle.k,1),0);
for zix = info.tem.model.variables.states.c.cSoil.zix
    p.cCycle.kin(:,zix)	= max(min(p.cCycle.kin(:,zix).*fe.cTaufTsoil.fT(:,tix).*fe.cTaufwSoil.BGME(:,tix).*p.cTaufLAI.kfLAI,1),0);
end

% COMPUTE TOTAL RESPIRATION AND NPP FOR EACH VEGETATION POOL AND FOR THE
% TOTAL FLUXES
fx.cNPP(:,tix)  = 0;
fx.cRA(:,tix)   = 0;
for zix = info.tem.model.variables.states.c.cVeg.zix
    % net primary production: NPP = GPP * allocationToPool - R_a
    s.cd.cNPP(:,zix)	= fx.gpp(:,tix) .* s.cd.cAlloc(:,zix) - s.cd.cEcoEfflux(:,zix);
    
    
    
    
    % full NPP and GPPS
    fx.cNPP(:,tix)      = fx.cNPP(:,tix) + s.cd.cNPP(:,zix);
    fx.cRA(:,tix)       = fx.cRA(:,tix) + s.cd.cEcoEfflux(:,zix);
    % ALLOCATION NPP TO pvegETATION POOLS
    s.c.cEco(:,zix)	= s.c.cEco(:,zix) + s.cd.cNPP(:,zix); % WARNING, HERE ONE SHOULD USE PREVIOUS
    
    
%     pool = previous pool + (gpp*allocation - already any calculated flux) + transfers to this pool - k * previous pool; this shoudl work for all!!
    % waiting for sujan's notes on our codes.
    
end

% CALCULATE FOLIAGE AND ROOT CARBON LOST AS LITTER AND DECREMENT PLANT
% CARBON POOLS
for zix = info.tem.model.variables.states.c.cVeg.zix
    s.cd.cOutPot(:,zix)  = min(s.c.cEco(:,zix),s.c.cEco(:,zix) .* p.cCycle.kin(:,zix));
    s.c.cEco(:,zix)	= s.c.cEco(:,zix) - s.cd.cOutPot(:,zix);
end


%% this needs to go somewhere else...
MTF     = fe.cCycle.MTF;
BGME	= d.cTaufwSoil.BGME(:,tix);
%%


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
	s.cd.cEcoEfflux(:,zix)	= 0; % very dangerous...
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
