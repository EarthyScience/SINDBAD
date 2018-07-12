function [f,fe,fx,s,d,p] = dyna_RAact_Thornley2000B(f,fe,fx,s,d,p,info,tix)
% #########################################################################
% FUNCTION	: prec_RAact_Thornley2000B
% 
% PURPOSE	: precomputations to estimate autotrophic respiration as
% maintenance + growth respiration according to Thornley and Cannell
% (2000): MODEL B - growth respiration is given priority (check Fig.1
% of the paper).
% 
% Computes the km (maintenance (respiration) coefficient) 
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
% 
% fT            : temperature effect on autrotrophic respiration (deltaT-1)
%               (fe.RAfTair.fT)
% RMN           : nitrogen efficiency rate of maintenance respiration
%               (gC.gN-1.deltaT-1) 
%               (p.RAact.RMN)
% C2N           : carbon to nitrogen ratio (gC.gN-1)
%               (p.RAact.C2N(zix))
% StepsPerDay	: number of time steps per day
%               (info.timeScale.stepsPerDay)
% YG            : growth yield coefficient - or growth efficiency (gC.gC-1)
%               (p.RAact.YG)
% 
% OUTPUTS
% km        : maintenance (respiration) coefficient - dependent on
%           temperature and, depending on the models, degradable fraction
%           (deltaT-1)
%           (fe.RAact.km(ii).value)
% 
% #########################################################################

% adjust nitrogen efficiency rate of maintenance respiration
%sujan RMN     = p.RAact.RMN ./ info.timeScale.stepsPerDay;
RMN     = p.RAact.RMN ./ info.tem.model.time.nStepsDay;

% compute maintenance and growth respiration terms for each vegetation pool
% according to MODEL B - growth respiration is given priority
for zix = info.tem.model.variables.states.c.cVeg.zix

    % scalars of maintenance respiration for models A, B and C
    % km is the maintenance respiration coefficient (d-1)
    s.cd.p_RAact_km(:,zix)    = 1 ./ s.cd.p_RAact_C2N(:,zix) .* RMN .* fe.RAfTair.fT;
    s.cd.p_RAact_km4su(:,zix)	= s.cd.p_RAact_km(:,zix);
    
    % growth respiration: R_g = (1 - YG) * GPP * allocationToPool
    s.cd.RA_G(:,zix)	= (1 - p.RAact.YG) .* fx.gpp(:,tix) .* d.cAlloc.cAlloc(:,zix,tix);
%     s.cd.RA_G(:,zix)	= (1 - p.RAact.YG) .* fx.gpp(:,tix) .*
%     s.cd.cAlloc(:,zix); %sujan
    
    % maintenance respiration: R_m = km * (C + YG * GPP * allocationToPool)
    s.cd.RA_M(:,zix)	= fe.RAact.km(zix).value(:,tix) .* (s.c.cEco(:,zix) + p.RAact.YG .* fx.gpp(:,tix) .* d.cAlloc.cAlloc(:,zix,tix));
%     s.cd.RA_M(:,zix)	= fe.RAact.km(zix).value(:,tix) .* (s.c.cEco(:,zix)
%     + p.RAact.YG .* fx.gpp(:,tix) .* s.cd.cAlloc(:,zix)); %sujan
    
    % total respiration per pool: R_a = R_m + R_g
    s.cd.cEcoEfflux(:,zix)	= s.cd.RA_M(:,zix) + s.cd.RA_G(:,zix);

end

end % function
