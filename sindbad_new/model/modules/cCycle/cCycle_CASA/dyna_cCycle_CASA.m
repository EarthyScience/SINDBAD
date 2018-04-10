function [fx,s,d] = dyna_cCycle_CASA(f,fe,fx,s,d,p,info,tix)
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
% fe.RHfwSoil.BGME
% d.cAlloc.c2pool
% s.cPools(ii).value
% fe.cCycle.DecayRate(ii).value
% fe.cCycle.ctransfer
% 
% OUTPUT
% s.cPools
% fx.efflux
% 
% #########################################################################

MTF     = fe.cCycle.MTF;
BGME	= d.RHfwSoil.BGME(:,tix);

% ALLOCATION NPP TO pvegETATION POOLS
for ii = 1:4
    s.cPools(ii).value	= s.cPools(ii).value + fx.cNpp(ii).value(:,tix);
end

POTcOUT	= zeros(info.forcing.size(1),numel(s.cPools));

% CALCULATE FOLIAGE AND ROOT CARBON LOST AS LITTER AND DECREMENT PLANT
% CARBON POOLS
for ii = 1:4
    POTcOUT(:,ii)  = min(s.cPools(ii).value,s.cPools(ii).value .* fe.cCycle.DecayRate(ii).value(:,tix));
    s.cPools(ii).value	= s.cPools(ii).value - POTcOUT(:,ii);
end

% INCREMENT LITTER CARBON POOLS - out of leafs
s.cPools(5).value	= s.cPools(5).value + POTcOUT(:,4) .* MTF;
s.cPools(6).value	= s.cPools(6).value + POTcOUT(:,4) .* (1 - MTF);

% INCREMENT LITTER CARBON POOLS - out of wood
s.cPools(9).value	= s.cPools(9).value + POTcOUT(:,3);

% INCREMENT LITTER CARBON POOLS - out of roots
s.cPools(7).value   = s.cPools(7).value + POTcOUT(:,1) .* MTF;
s.cPools(8).value   = s.cPools(8).value + POTcOUT(:,1) .* (1 - MTF);
s.cPools(10).value	= s.cPools(10).value + POTcOUT(:,2);

% DETERMINE MAXIMUM FLUXES FROM EACH CARBON POOL
for ii = 5:14
    POTcOUT(:,ii)   = min(s.cPools(ii).value, s.cPools(ii).value .* fe.cCycle.kfEnvTs(ii).value(:,tix) .* BGME);
    % make sure the soil respiratory fluxes are 0
	fx.cEfflux(ii).value(:,tix)	= 0;
end

% COMPUTE CARBON FLUXES IN THE psoil
flux_order  = [9 8 11 2 1 12 4 3 6 5 16 15 7 14 13 10];
for ij = 1:numel(flux_order)
    ii                              = flux_order(ij); % this saves, like, 1/3 of the time in the function...
    idonor                          = fe.cCycle.ctransfer(ii).donor;
    ireceiver                       = fe.cCycle.ctransfer(ii).receiver;
    cOUT                            = POTcOUT(:,idonor) .* fe.cCycle.ctransfer(ii).xtrEFF;
    s.cPools(idonor).value          = s.cPools(idonor).value    - cOUT;
    s.cPools(ireceiver).value       = s.cPools(ireceiver).value + cOUT .* fe.cCycle.ctransfer(ii).effFLUX;
    fx.cEfflux(idonor).value(:,tix)   = fx.cEfflux(idonor).value(:,tix)  + cOUT .* (1 - fe.cCycle.ctransfer(ii).effFLUX);
end

% feed the rh fluxes
fx.rh(:,tix)  = 0;
for ii = 5:14
	fx.rh(:,tix)	= fx.rh(:,tix) + fx.cEfflux(ii).value(:,tix);
end

end % function
