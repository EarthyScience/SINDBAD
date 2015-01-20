function [fe,fx,d,p] = Prec_RdiffEffectGPP_Turner(f,fe,fx,s,d,p,info)
% #########################################################################
% PURPOSE	: diffuse radiation effect on GPP
% 
% REFERENCES: Turner et al XXXX
% 
% CONTACT	: mjung, ncarval
% 
% INPUT
% Rg        : global incoming radiation [MJ/m2/time]
%           (f.Rg)
% 
% RgPot     : potential global incoming radiation [MJ/m2/time]
%           (f.RgPot)
% 
% rue1      : maximum radiation use efficiency for direct radiation 
% 
% rue2
% 
% OUTPUT
% rueGPP    : maximum instantaneous radiation use efficiency [gC/MJ]
%           (d.RdiffEffectGPP.rueGPP)
% 
% DEPENDENCIES  :
% 
% NOTES:
% 
% #########################################################################

tmp                             = ones(1,info.forcing.size(2));
prue2                           = p.RdiffEffectGPP.rue2 * tmp;
prue1                           = p.RdiffEffectGPP.rue1 * tmp;
d.RdiffEffectGPP.rueGPP         = prue1;
valid                           = f.RgPot > 0;
d.RdiffEffectGPP.rueGPP(valid)	= (prue2(valid) - prue1(valid)) .* (1 - f.Rg(valid) ./ f.RgPot(valid) ) + prue1(valid);

end