function [fx,s,d] = CCycle_CASA(f,fe,fx,s,d,p,info,i)
% #########################################################################
% FUNCTION	: CCycle_CASA
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
% fe.CCycle.MTF
% fe.SoilMoistEffectRH.BGME
% d.CAllocationVeg.c2pool
% s.cPools(ii).value
% fe.CCycle.DecayRate(ii).value
% fe.CCycle.ctransfer
% 
% OUTPUT
% s.cPools
% fx.efflux
% 
% #########################################################################

MTF     = fe.CCycle.MTF;
BGME	= d.SoilMoistEffectRH.BGME(:,i);

% ALLOCATION NPP TO VEGETATION POOLS
for ii = 1:4
    s.cPools(ii).value	= s.cPools(ii).value + fx.cNpp(ii).value(:,i);
end

POTcOUT	= zeros(info.forcing.size(1),numel(s.cPools));

% CALCULATE FOLIAGE AND ROOT CARBON LOST AS LITTER AND DECREMENT PLANT
% CARBON POOLS
for ii = 1:4
    POTcOUT(:,ii)  = s.cPools(ii).value .* fe.CCycle.DecayRate(ii).value(:,i);
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
    POTcOUT(:,ii)   = s.cPools(ii).value .* fe.CCycle.kfEnvTs(ii).value(:,i) .* BGME;
end

% COMPUTE CARBON FLUXES IN THE SOIL
flux_order  = [9 8 11 2 1 12 4 3 6 5 16 15 7 14 13 10];
for ij = 1:numel(flux_order)
    ii                              = flux_order(ij); % this saves, like, 1/3 of the time in the function...
    idonor                          = fe.CCycle.ctransfer(ii).donor;
    ireceiver                       = fe.CCycle.ctransfer(ii).receiver;
    cOUT                            = POTcOUT(:,idonor) .* fe.CCycle.ctransfer(ii).xtrEFF;
    s.cPools(idonor).value          = s.cPools(idonor).value    - cOUT;
    s.cPools(ireceiver).value       = s.cPools(ireceiver).value + cOUT .* fe.CCycle.ctransfer(ii).effFLUX;
    fx.cEfflux(idonor).value(:,i)   = fx.cEfflux(idonor).value(:,i)  + cOUT .* (1 - fe.CCycle.ctransfer(ii).effFLUX);
end

% feed the rh fluxes
for ii = 5:14
	fx.rh(:,i)	= fx.rh(:,i) + fx.cEfflux(ii).value(:,i);
end

end % function
