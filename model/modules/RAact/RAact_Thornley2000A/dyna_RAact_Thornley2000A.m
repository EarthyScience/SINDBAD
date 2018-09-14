function [f,fe,fx,s,d,p] = dyna_RAact_Thornley2000A(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% FUNCTION	: dyna_RAact_Thornley2000A
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
% cEco      : carbon pools (gC.m-2) 
%           (s.c.cEco)
% c2pool    : carbon allocation in the different vegetation pools ([])
%           (s.cd.cAlloc(:,zix))
% YG        : growth yield coefficient - or growth efficiency (gC.gC-1)
%           (p.RAact.YG)
% km        : maintenance (respiration) coefficient - dependent on
%           temperature and, depending on the models, degradable fraction
%           (deltaT-1)
%           (fe.RAact.km(ii).value)
% 
% OUTPUTS
% efflux    : autotrophic respiration from each plant pools (gC.m-2.deltaT-1)
%           (s.cd.cEcoEfflux(:,zix))
% cNpp      : net primary production for each plant pool (gC.m-2.deltaT-1)
%           (s.cd.cNPP)
% 
% #########################################################################

% 
% Questions - practical - leave RAact per pool, or make a field fx.ra
% that has all the autotrophic respiration components together?
% #########################################################################

% adjust nitrogen efficiency rate of maintenance respiration to the current
% model time step
%sujan RMN     = p.RAact.RMN ./ info.timeScale.stepsPerDay;
RMN     = p.RAact.RMN ./ info.tem.model.time.nStepsDay;


% compute maintenance and growth respiration terms for each vegetation pool
% according to MODEL A - maintenance respiration is given priority
for zix = info.tem.model.variables.states.c.zix.cVeg
    
    % scalars of maintenance respiration for models A, B and C
    % km is the maintenance respiration coefficient (d-1)
    s.cd.p_RAact_km(:,zix)    = 1 ./ s.cd.p_RAact_C2N(:,zix) .* RMN .* fe.RAfTair.fT(:,tix);
    s.cd.p_RAact_km4su(:,zix)	= s.cd.p_RAact_km(:,zix) .* p.RAact.YG;
    
    % maintenance respiration first: R_m = km * C
    s.cd.RA_M(:,zix)	= s.cd.p_RAact_km(:,zix) .* s.c.cEco(:,zix);
    
    % growth respiration: R_g = (1 - YG) * (GPP * allocationToPool - R_m)
    s.cd.RA_G(:,zix)	= (1 - p.RAact.YG) .* (fx.gpp(:,tix) .* s.cd.cAlloc(:,zix) - s.cd.RA_M(:,zix));
    
    % no negative growth respiration
    s.cd.RA_G(s.cd.RA_G(:,zix) < 0,zix)	= 0;
    
    % total respiration per pool: R_a = R_m + R_g
    s.cd.cEcoEfflux(:,zix)	= s.cd.RA_M(:,zix) + s.cd.RA_G(:,zix);

end

end % function
