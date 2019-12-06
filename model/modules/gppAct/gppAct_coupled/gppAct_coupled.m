function [f,fe,fx,s,d,p] = gppAct_coupled(f,fe,fx,s,d,p,info,tix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% PURPOSE	: estimate transpiration from GPP
% 
% REFERENCES:
% 
% CONTACT	: mjung, ncarval
% 
% INPUT
% gpp       : actual GPP [gC/m2/time]
%           (fx.gpp)
% AoE       : water use efficiency - ratio of assimilation and
%           transpiration fluxes [gC/mmH2O]
%           (d.WUE.AoE)
% 
% OUTPUT
% tranAct    : transpiration [mm/m2/time]
%           (fx.tranAct)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% calculate transpiration
AoE                     =   d.WUE.AoE(:,tix);
tranSup                 =   d.tranSup.tranSup(:,tix);
gppSup                  =   tranSup .* AoE;  
gppDem                  =   d.gppDem.gppE(:,tix);
gppAct                  =   nanmin(gppSup,gppDem);
fx.gpp(:,tix)           =   gppAct;

end