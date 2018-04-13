function [fe,fx,d,p,f] = prec_cTaufpVeg_CASA(f,fe,fx,s,d,p,info)




% CALCULATE FRACTION OF LITTER THAT WILL BE METABOLIC FROM LIGNIN:N RATIO
% CALCULATE LIGNIN 2 NITROGEN SCALAR
L2N     = (p.cTaufpVeg.LITC2N .* p.cTaufpVeg.LIGNIN) .* p.cTaufpVeg.NONSOL2SOLLIGNIN;

% DETERMINE FRACTION OF LITTER THAT WILL BE METABOLIC FROM LIGNIN:N RATIO
MTF             = p.cTaufpVeg.MTFA - (p.cTaufpVeg.MTFB .* L2N);
MTF(MTF < 0)    = 0;
p.cCycle.MTF    = MTF;

% DETERMINE FRACTION OF C IN STRUCTURAL LITTER POOLS FROM LIGNIN
p.cCycle.SCLIGNIN    = (p.cTaufpVeg.LIGNIN .* p.cTaufpVeg.C2LIGNIN .* p.cTaufpVeg.NONSOL2SOLLIGNIN) ./ (1 - MTF);

% DETERMINE EFFECT OF LIGNIN CONTENT ON k OF S_LEAF AND S_ROOT
p.cCycle.LIGEFF = exp(-p.cTaufpVeg.LIGEFFA .* p.cCycle.SCLIGNIN);
p.cCycle.k(6)   = p.cCycle.k(6) .* p.cCycle.LIGEFF;
p.cCycle.k(8)   = p.cCycle.k(8) .* p.cCycle.LIGEFF;


end %function
