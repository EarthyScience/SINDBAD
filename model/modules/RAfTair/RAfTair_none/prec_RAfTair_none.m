function [f,fe,fx,s,d,p] = prec_RAfTair_none(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% FUNCTION    : prec_RAfTair_none
% 
% PURPOSE    : estimate the effect of temperature in autotrophic maintenance
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
% CONTACT    : Nuno
% 
% INPUTS
% Tsoil     : soil temperature (?C)
% Tair      : air temperature (?C) 
% Q10_RM    : q10 parameter ([])
% Tref_RM    : reference temperature (?C)
% 
% OUTPUTS
% fT    : autotrophic respiration from each plant pools (gC.m-2.deltaT-1)
%           (fe.RAfTair.fT)
% 
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


% just copy
fe.RAfTair.fT    = info.tem.helpers.arrays.onespixtix;

end
