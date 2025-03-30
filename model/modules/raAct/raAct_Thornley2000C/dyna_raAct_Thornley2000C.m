function [f,fe,fx,s,d,p] = dyna_raAct_Thornley2000C(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Precomputations to estimate autotrophic respiration as
% maintenance + growth respiration according to Thornley and Cannell
% (2000): MODEL C - growth, degradation and resynthesis view of respiration
% (check Fig.1 of the paper). 
% Computes the km (maintenance (respiration) coefficient)
%
% Inputs:
%   - fe.rafTair.fT:              temperature effect on autrotrophic respiration (deltaT-1)
%   - p.raAct.RMN:                nitrogen efficiency rate of maintenance respiration
%                                 (gC.gN-1.deltaT-1)
%   - p.cCycleBase.C2Nveg(zix):   carbon to nitrogen ratio (gC.gN-1)
%   - fe.cCycle.MTF:              metabolic fraction ([])
%   - p.raAct.YG:                 growth yield coefficient - or growth efficiency (gC.gC-1)
%   - info.timeScale.stepsPerDay: number of time steps per day

% Outputs:
%   - fe.raAct.km(ii).value: maintenance (respiration) coefficient - dependent on
%           temperature and, depending on the models, degradable fraction
%           (deltaT-1)

% Modifies:
%  
%
% References:
% Amthor, J. S. (2000), The McCree-de Wit-Penning de Vries-Thornley
% respiration paradigms: 30 years later, Ann Bot-London, 86(1), 1-20. 
% Ryan, M. G. (1991), Effects of Climate Change on Plant Respiration, Ecol
% Appl, 1(2), 157-167.
% 
% Thornley, J. H. M., and M. G. R. Cannell (2000), Modelling the components
% of plant respiration: Representation and realism, Ann Bot-London, 85(1),
% 55-67.
%
% Created by:
%   - Nuno Carvalhais (ncarval)
%
% Versions:
%   - 1.0 on 06.02.2020 (sbesnard): cleaned up the code
%
% Notes :
% Fd is the decomposable fraction from each plant pool (see Thornley and
% Cannell 2000). Since we don't discriminate in the model, this should be
% based on literature values (e.g. sap to hard wood ratios). Before this
% fraction was made equivalent to the metabolic fraction in residues -
% strong assumption. Until somebody looks at this, we keep the same
% approach and add a flag to model parameters to switch it off.
% Another thing to consider is if this a double count, since we have C2N
% ratios?
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% adjust nitrogen efficiency rate of maintenance respiration
%sujan RMN     = p.raAct.RMN ./ info.timeScale.stepsPerDay;
RMN     = p.raAct.RMN ./ info.tem.model.time.nStepsDay;

for zix = info.tem.model.variables.states.c.zix.cVeg
    % make the Fd of each pool equal to the MTF
    if p.raAct.flagMTF
        p.raAct.Fd(:,zix) = fe.cTaufpVeg.MTF;
    else
        p.raAct.Fd(:,zix) = 1;
    end
    
    % scalars of maintenance respiration for models A, B and C
    % km is the maintenance respiration coefficient (d-1)
    km                      = 1 ./ s.cd.p_cCycleBase_C2Nveg(:,zix) .* RMN .* fe.rafTair.fT(:,tix);
    kd                      = p.raAct.Fd(:,zix);
    s.cd.p_raAct_km(:,zix)    = km .* kd;
    s.cd.p_raAct_km4su(:,zix)    = s.cd.p_raAct_km(:,zix) .* (1 - p.raAct.YG);
    
    % compute maintenance and growth respiration terms for each vegetation pool
    % according to MODEL C - growth, degradation and resynthesis view of
    % respiration
    % maintenance respiration: R_m = km .* (1 - YG) .* C; km = km .* MTF (before equivalent to kd)
    s.cd.RA_M(:,zix)    = s.cd.p_raAct_km(:,zix) .* (1 - p.raAct.YG) .* s.c.cEco(:,zix);
    
    % growth respiration: R_g = gpp .* (1 - YG)
    s.cd.RA_G(:,zix)    = (1 - p.raAct.YG) .* fx.gpp(:,tix) .* s.cd.cAlloc(:,zix);
    
    % total respiration per pool: R_a = R_m + R_g
    s.cd.cEcoEfflux(:,zix)    = s.cd.RA_M(:,zix) + s.cd.RA_G(:,zix);
end

end
