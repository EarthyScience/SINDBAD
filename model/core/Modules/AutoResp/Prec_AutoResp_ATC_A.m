function [fe,fx,d,p] = Prec_AutoResp_ATC_A(f,fe,fx,s,d,p,info)
% #########################################################################
% FUNCTION	: Prec_AutoResp_ATC_A
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
%               (d.TempEffectAutoResp.fT)
%               example
%               d.TempEffectAutoResp.fT(1).value - temperature effect of
%               RespAuto of fine roots (pool (1)). 
% RMN           : nitrogen efficiency rate of maintenance respiration
%               (gC.gN-1.deltaT-1) 
%               (p.AutoResp.RMN)
% C2N           : carbon to nitrogen ratio (gC.gN-1)
%               (p.AutoResp.C2N)
%               example
%               p.AutoResp.C2N(2).value - C2N ratio of coarse roots
% stepsPerDay	: number of time steps per day
%               (info.timeScale.stepsPerDay)
% YG            : growth yield coefficient - or growth efficiency (gC.gC-1)
%               (p.AutoResp.YG)
% 
% OUTPUTS
% km        : maintenance (respiration) coefficient - dependent on
%           temperature and, depending on the models, degradable fraction
%           (deltaT-1)
%           (fe.AutoResp.km(ii).value)
% 
% #########################################################################

% adjust nitrogen efficiency rate of maintenance respiration to the current
% model time step
RMN     = p.AutoResp.RMN ./ info.timeScale.stepsPerDay;

% scalars of maintenance respiration for models A, B and C
% km is the maintenance respiration coefficient (d-1)
for ii = 1:4 % for all the vegetation pools
    fe.AutoResp.km(ii).value	= 1 ./ p.AutoResp.C2N(ii).value .* RMN .* d.TempEffectAutoResp.fT(ii).value;
    fe.AutoResp.kmYG(ii).value	= fe.AutoResp.km(ii).value .* p.AutoResp.YG;
end

end % function
