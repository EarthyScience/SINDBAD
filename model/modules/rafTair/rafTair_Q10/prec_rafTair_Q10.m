function [f,fe,fx,s,d,p] = prec_rafTair_Q10(f,fe,fx,s,d,p,info)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% estimate the effect of temperature in autotrophic maintenance
% respiration - q10 model
%
% Inputs:
%   - f.Tair: air temperature [degC] 
%   - p.rafTair.Q10_RM: q10 parameter []
%   - p.rafTair.Tref_RM: reference temperature [degC]
%
% Outputs:
%   - fe.rafTair.fT: autotrophic respiration rate [gC.m-2.deltaT-1]
%
% Modifies:
%   - 
%
% References:
%   -  Amthor, J. S. (2000), The McCree-de Wit-Penning de Vries-Thornley
%       respiration paradigms: 30 years later, Ann Bot-London, 86(1), 1-20. 
%   -  Ryan, M. G. (1991), Effects of Climate Change on Plant Respiration, Ecol
%       Appl, 1(2), 157-167.
%   -  Thornley, J. H. M., and M. G. R. Cannell (2000), Modelling the components
%       of plant respiration: Representation and realism, Ann Bot-London, 85(1),
%       55-67.
%
% Notes:
%   - 
%
% Created by:
%   - Nuno Carvalhais (ncarval)
%
% Versions:
%   - 1.0 on 22.11.2019 (skoirala): clean up
%
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%%
fe.rafTair.fT    = p.rafTair.Q10_RM .^ ((f.Tair - p.rafTair.Tref_RM) ./ 10);
end
