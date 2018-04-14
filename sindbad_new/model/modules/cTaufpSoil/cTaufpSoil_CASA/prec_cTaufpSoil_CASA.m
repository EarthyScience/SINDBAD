function [fe,fx,d,p,f] = prec_cTaufpSoil_CASA(f,fe,fx,s,d,p,info)

% TEXTURE EFFECT ON k OF cMicSoil
p.cTaufpSoil.kfSoil 		= ones(nPix,nZix);
p.cTaufpSoil.kfSoil(:,12)	= (1 - (p.cTaufpSoil.TEXTEFFA .* (p.psoil.SILT + p.psoil.CLAY)));


end %function
