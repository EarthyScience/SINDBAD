function d = initWd(d,info)

% initial value for pools
% S   = ones(info.forcing.size) .* 1E-10;
S0	= zeros(info.forcing.size);


d.SaturatedFraction.frSat	= S0;

d.SoilMoistEffectRH.BGME    = S0;
d.SoilMoistEffectRH.pBGME   = S0(:,1);

d.SupplyTransp.TranspS      = S0;

d.Temp.pwSM1    = S0(:,1);
d.Temp.pwSM2	= S0(:,1);



d.Temp.pwGW    = S0(:,1);
d.Temp.pwGWR   = S0(:,1);
d.Temp.pwSWE   = S0(:,1);
d.Temp.pwWTD   = S0(:,1);


d.Temp.pSMScGPP = S0(:,1) + 1;
d.SMEffectGPP.SMScGPP = S0 + 1;


end
