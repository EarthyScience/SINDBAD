function [f,fe,fx,s,d,p] = prec_cTaufpSoil_CASA(f,fe,fx,s,d,p,info)

    %sujan: moving clay and silt from p.soilTexture to s.wd.p_wSoilBase.
CLAY 					  =   mean(s.wd.p_wSoilBase_CLAY,2);
SILT 					  =   mean(s.wd.p_wSoilBase_SILT,2);

% TEXTURE EFFECT ON k OF cMicSoil
s.cd.p_cTaufpSoil_kfSoil 		= info.tem.helpers.arrays.onespixzix.c.cEco;
zix                             = info.tem.model.variables.states.c.zix.cMicSoil;
s.cd.p_cTaufpSoil_kfSoil(:,zix)	= (1 - (p.cTaufpSoil.TEXTEFFA .* (SILT + CLAY)));
% (ineficient, should be pix zix_mic)

end %function
