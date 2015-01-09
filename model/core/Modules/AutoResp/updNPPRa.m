function [fx,s,d] = updNPPRa(f,fe,fx,s,d,p,info,i)
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
%           (d.CAllocationVeg.c2pool)
% 
% OUTPUTS
% npp       : net primary production for each plant pool (gC.m-2.deltaT-1)
%           (fx.npp)
%           example
%           fx.npp(3).value - npp that goes to woody biomass.
% efflux    : autotrophic respiration from each plant pools (gC.m-2.deltaT-1)
%           (fx.cEfflux.value)
% 
% #########################################################################

% compute total respiration and npp for each vegetation pool
for ii = 1:4
    % total respiration: R_a = R_m + R_g
    fx.cEfflux(ii).value(:,i)	= fx.cEfflux(ii).maintenance(:,i) + fx.cEfflux(ii).growth(:,i);
    
    % net primary production: NPP = GPP * allocationToPool - R_a
    fx.npp(ii).value(:,i)	= fx.gpp(:,i) .* d.CAllocationVeg.c2pool(ii).value(:,i) - fx.cEfflux(ii).value(:,i);
    
end

end % function
