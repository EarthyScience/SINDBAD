function [fe,fx,d,p,f] = prec_cTaufpSoil_CASA(f,fe,fx,s,d,p,info)

% TEXTURE EFFECT ON k OF cMicSoil
s.cd.p_cTaufpSoil_kfSoil 		= ones(nPix,nZix);
zix                             = info.tem.model.variables.c.zix.cMicSoil;
s.cd.p_cTaufpSoil_kfSoil(:,zix)	= (1 - (p.cTaufpSoil.TEXTEFFA .* (p.psoil.SILT + p.psoil.CLAY)));
% (ineficient, should be pix zix_mic)

end %function
