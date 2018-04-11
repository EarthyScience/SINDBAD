function [fe,fx,d,p] = prec_RAact_Thornley2000A(f,fe,fx,s,d,p,info)
% #########################################################################
% FUNCTION	: prec_RAact_Thornley2000A
% 
% PURPOSE	: precomputations to estimate autotrophic respiration as
% maintenance + growth respiration according to Thornley and Cannell
% (2000): MODEL A - maintenance respiration is given priority (check Fig.1
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
%               (d.TempEffectRAact.fT)
%               example
%               d.TempEffectRAact.fT(1).value - temperature effect of
%               RespAuto of fine roots (pool (1)). 
% RMN           : nitrogen efficiency rate of maintenance respiration
%               (gC.gN-1.deltaT-1) 
%               (p.RAact.RMN)
% C2N           : carbon to nitrogen ratio (gC.gN-1)
%               (p.RAact.C2N)
%               example
%               p.RAact.C2N(2).value - C2N ratio of coarse roots
% stepsPerDay	: number of time steps per day
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

% adjust nitrogen efficiency rate of maintenance respiration to the current
% model time step
RMN     = p.RAact.RMN ./ info.timeScale.stepsPerDay;

% scalars of maintenance respiration for models A, B and C
% km is the maintenance respiration coefficient (d-1)
for ii = 1:4 % for all the vegetation pools
    fe.RAact.km(ii).value	= 1 ./ p.RAact.C2N(ii).value .* RMN .* d.TempEffectRAact.fT(ii).value;
    fe.RAact.km4su(ii).value	= fe.RAact.km(ii).value .* p.RAact.YG;
end

end % function
