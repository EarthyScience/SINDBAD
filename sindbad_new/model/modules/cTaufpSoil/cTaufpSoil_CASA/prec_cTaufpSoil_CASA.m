function [fe,fx,d,p,f] = prec_cTaufpSoil_CASA(f,fe,fx,s,d,p,info)

% TEXTURE EFFECT ON k OF SOIL_MIC
p.cCycle.TEXTEFF	= (1 - (p.cCycle.TEXTEFFA .* (p.psoil.SILT + p.psoil.CLAY)));
p.cCycle.k(12)      = p.cCycle.k(12) .* p.cCycle.TEXTEFF;


end %function
