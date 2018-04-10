function d = initWd(d,info)

% initialize to full capacity
d.Temp.pwSM	= info.params.SOIL.tAWC;

% no initial water stress in soil microbial decomposition
d.SoilMoistEffectRH.pBGME   = info.helper.ones1d;

% no initial water stress in GPP
d.Temp.pSMScGPP         = info.helper.ones1d;
d.SMEffectGPP.SMScGPP   = info.helper.ones2d;

% previous time steps in water
d.Temp.pwGW    = info.params.SOIL.tAWC;
d.Temp.pwGWR   = info.helper.zeros1d;
d.Temp.pwSWE   = info.helper.zeros1d;
% d.Temp.pwWTD   = info.helper.zeros1d;

end % function
