function [fx,s,d] = raJact_Thornley2000A(f,fe,fx,s,d,p,info,i)
% #########################################################################
% FUNCTION	: raJact_Thornley2000A
% 
% PURPOSE	: estimate autotrophic respiration as maintenance + growth
% respiration according to Thornley and Cannell (2000): MODEL A -
% maintenance respiration is given priority (check Fig.1 of the paper).
% 
% REFERENCES:
% Amthor, J. S. (2000), The McCree-de Wit-Penning de Vries-Thornley
% respiration paradigms: 30 years later, Ann Bot-London, 86(1), 1-20. 
% Ryan, M. G. (1991), Effects of Climate Change on Plant Respiration, Ecol
% Appl, 1(2), 157-167.
% 
% Thornley, J. H. M., and M. G. R. Cannell (2000), Modelling the components
% of plant respiration: Representation and realism, Ann Bot-London, 85(1),
% 55-67.
% 
% CONTACT	: Nuno
% 
% INPUTS
% gpp       : substrate supply rate: Gross Primary Production (gC.m-2.deltaT-1)
%           (fx.gpp) 
% cPools	: carbon pools (gC.m-2) 
%           (s.cPools)
% c2pool    : carbon allocation in the different vegetation pools ([])
%           (d.CAllocationVeg.c2pool)
% YG        : growth yield coefficient - or growth efficiency (gC.gC-1)
%           (p.AutoResp.YG)
% km        : maintenance (respiration) coefficient - dependent on
%           temperature and, depending on the models, degradable fraction
%           (deltaT-1)
%           (fe.AutoResp.km(ii).value)
% 
% OUTPUTS
% efflux    : autotrophic respiration from each plant pools (gC.m-2.deltaT-1)
%           (fx.cEfflux)
%           example
%           fx.cEfflux(1).maintenance - maintenance respiration of fine
%           roots.
%           fx.cEfflux(3).growth - growth respiration of woody biomass.
%           fx.cEfflux(4).value - total (growth + maintenance)
%           respiration of leaf pools
% cNpp      : net primary production for each plant pool (gC.m-2.deltaT-1)
%           (fx.cNpp)
%           example
%           fx.cNpp(3).value - npp that goes to woody biomass.
% 
% #########################################################################

% 
% Questions - practical - leave AutoResp per pool, or make a field fx.ra
% that has all the autotrophic respiration components together?
% #########################################################################

% compute maintenance and growth respiration terms for each vegetation pool
% according to MODEL A - maintenance respiration is given priority
for ii = 1:4
    % maintenance respiration first: R_m = km * C
    fx.cEfflux(ii).maintenance(:,i)	= fe.AutoResp.km(ii).value(:,i) .* s.cPools(ii).value;
    
    % growth respiration: R_g = (1 - YG) * (GPP * allocationToPool - R_m)
    fx.cEfflux(ii).growth(:,i)	= (1 - p.AutoResp.YG) .* (fx.gpp(:,i) .* d.CAllocationVeg.c2pool(ii).value(:,i) - fx.cEfflux(ii).maintenance(:,i));
    
    % no negative growth respiration
    fx.cEfflux(ii).growth(fx.cEfflux(ii).growth(:,i) < 0, i)	= 0;
    
end

% compute total respiration and npp for each vegetation pool
[fx,s,d]	= calcUpdNPPRa(f,fe,fx,s,d,p,info,i);

end % function
