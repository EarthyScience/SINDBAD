function [f,fe,fx,s,d,p] = dyna_RAact_Thornley2000C(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% FUNCTION	: dyna_RAact_Thornley2000C
% 
% PURPOSE	: estimate autotrophic respiration as maintenance + growth
% respiration according to Thornley and Cannell (2000): MODEL C -
% growth, degradation and resynthesis view of respiration (check Fig.1 of
% the paper).
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
% cEco      : carbon pools (gC.m-2) 
%           (s.c.cEco)
% c2pool    : carbon allocation in the different vegetation pools ([])
%           (d.cAlloc.c2pool)
% YG        : growth yield coefficient - or growth efficiency (gC.gC-1)
%           (p.RAact.YG)
% km        : maintenance (respiration) coefficient - dependent on
%           temperature and, depending on the models, degradable fraction
%           (deltaT-1)
%           (fe.RAact.km(ii).value)
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
% Questions - practical - leave RAact per pool, or make a field fx.ra
% that has all the autotrophic respiration components together?
% #########################################################################

% compute maintenance and growth respiration terms for each vegetation pool
% according to MODEL C - growth, degradation and resynthesis view of
% respiration
for zix = info.tem.model.variables.states.c.cVeg.zix
    % maintenance respiration: R_m = km * (1 - YG) * C; km = km * MTF (before equivalent to kd)
    fx.cEfflux(zix).maintenance(:,tix)	= fe.RAact.km(zix).value(:,tix) .* (1 - p.RAact.YG) .* s.c.cEco(:,zix);
    
    % growth respiration: R_g = gpp * (1 - YG)
    fx.cEfflux(zix).growth(:,tix)	= (1 - p.RAact.YG) .* fx.gpp(:,tix) .* d.cAlloc.c2pool(zix).value(:,tix);
    
end

% compute total respiration and npp for each vegetation pool
[f,fe,fx,s,d,p]	= calcUpdNPPRa(f,fe,fx,s,d,p,info,tix);

end % function
