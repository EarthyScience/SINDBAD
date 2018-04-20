function [fe,fx,d,p,f] = prec_cTaufpSoil_CASA(f,fe,fx,s,d,p,info)

% TEXTURE EFFECT ON k OF cMicSoil
p.cTaufpSoil.kfSoil 		= ones(nPix,nZix);
zix                         = info.tem.model.variables.c.zix.cMicSoil;
p.cTaufpSoil.kfSoil(:,zix)	= (1 - (p.cTaufpSoil.TEXTEFFA .* (p.psoil.SILT + p.psoil.CLAY)));


end %function
