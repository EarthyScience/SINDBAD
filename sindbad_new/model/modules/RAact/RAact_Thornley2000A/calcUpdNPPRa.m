function [fx,s,d,f] = calcUpdNPPRa(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% FUNCTION	: updNPPRa
% 
% PURPOSE	: update the flux fields after autotrophic respiration.
% 
% REFERENCES:
% Amthor, J. S. (2000), The McCree-de Wit-Penning de Vries-Thornley
% respiration paradigms: 30 years later, Ann Bot-London, 86(1), 1-20. 
% Ryan, M. G. (1991), Effects of Climate Change on Plant Respiration, Ecol
% Appl, 1(2), 157-167.
% 
% CONTACT	: Nuno
% 
% INPUTS
% gpp       : substrate supply rate: Gross Primary Production (gC.m-2.deltaT-1)
%           (fx.gpp) 
% efflux    : autotrophic respiration from each plant pools (gC.m-2.deltaT-1)
%           (fx.cEfflux)
%           example
%           fx.cEfflux(1).maintenance - maintenance respiration of fine
%           roots.
%           fx.cEfflux(3).growth - growth respiration of woody biomass.
%           fx.cEfflux(4).value - total (growth + maintenance)
%           respiration of leaf pools
% c2pool    : carbon allocation in the different vegetation pools ([])
%           (d.cAlloc.c2pool)
% 
% OUTPUTS
% cNpp      : net primary production for each plant pool (gC.m-2.deltaT-1)
%           (fx.cNpp)
%           example
%           fx.cNpp(3).value - npp that goes to woody biomass.
% npp       : net primary production (gC.m-2.deltaT-1)
%           (fx.npp)
%           example
% efflux    : autotrophic respiration from each plant pools (gC.m-2.deltaT-1)
%           (fx.cEfflux.value)
% 
% #########################################################################

% compute total respiration and npp for each vegetation pool and for the
% total fluxes
fx.npp(:,tix) = 0;
fx.ra(:,tix)  = 0;
for ii = 1:4
    % total respiration per pool: R_a = R_m + R_g
    fx.cEfflux(ii).value(:,tix)	= fx.cEfflux(ii).maintenance(:,tix) + fx.cEfflux(ii).growth(:,tix);
    
    % net primary production: NPP = GPP * allocationToPool - R_a
    fx.cNpp(ii).value(:,tix)	= fx.gpp(:,tix) .* d.cAlloc.c2pool(ii).value(:,tix) - fx.cEfflux(ii).value(:,tix);
    
    % npp/ra
    fx.npp(:,tix)	= fx.npp(:,tix) + fx.cNpp(ii).value(:,tix);
    fx.ra(:,tix)	= fx.ra(:,tix) + fx.cEfflux(ii).value(:,tix);
    
end

end % function
