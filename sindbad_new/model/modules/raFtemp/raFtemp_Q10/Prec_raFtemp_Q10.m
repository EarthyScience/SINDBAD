function [fe,fx,d,p] = Prec_raFtemp_Q10(f,fe,fx,s,d,p,info)
% #########################################################################
% FUNCTION	: Prec_raFtemp_Q10
% 
% PURPOSE	: estimate the effect of temperature in autotrophic maintenance
% respiration - q10 model.
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
% Tsoil     : soil temperature (ºC)
% Tair      : air temperature (ºC) 
% Q10_RM    : q10 parameter ([])
% Tref_RM	: reference temperature (ºC)
% 
% OUTPUTS
% fT    : autotrophic respiration from each plant pools (gC.m-2.deltaT-1)
%           (d.TempEffectAutoResp.fT)
%           example
%           d.TempEffectAutoResp.fT(1).value - effect of temperature on
%           maintenance respiration of fine roots. 
% 
% #########################################################################

% calculate temperature effect on plant maintenance respiration (1 and 2
% corresponds to roots; 3 and 4 corresponds to wood and leafs)
d.TempEffectAutoResp.fT(1).value	= p.TempEffectAutoResp.Q10_RM .^ ((f.Tsoil - p.TempEffectAutoResp.Tref_RM) ./ 10);
d.TempEffectAutoResp.fT(2).value	= p.TempEffectAutoResp.Q10_RM .^ ((f.Tsoil - p.TempEffectAutoResp.Tref_RM) ./ 10);
d.TempEffectAutoResp.fT(3).value	= p.TempEffectAutoResp.Q10_RM .^ ((f.Tair - p.TempEffectAutoResp.Tref_RM) ./ 10);
d.TempEffectAutoResp.fT(4).value	= p.TempEffectAutoResp.Q10_RM .^ ((f.Tair - p.TempEffectAutoResp.Tref_RM) ./ 10);

end % function
