function [f,fe,fx,s,d,p] = prec_cTaufpSoil_CASA(f,fe,fx,s,d,p,info)

% TEXTURE EFFECT ON k OF cMicSoil
s.cd.p_cTaufpSoil_kfSoil 		= info.tem.helpers.arrays.onespixzix.c.cEco;
zix                             = info.tem.model.variables.states.c.zix.cMicSoil;
s.cd.p_cTaufpSoil_kfSoil(:,zix)	= (1 - (p.cTaufpSoil.TEXTEFFA .* (p.soilTexture.SILT + p.soilTexture.CLAY)));
% (ineficient, should be pix zix_mic)

end %function
