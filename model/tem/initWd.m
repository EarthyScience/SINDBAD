function d = initWd(d,info)

% initial value for pools
% S   = ones(info.forcing.size) .* 1E-10;
S0	= zeros(info.forcing.size);
% S1	= zeros(info.forcing.size);


d.SaturatedFraction.frSat	= S0;

d.SoilMoistEffectRH.BGME    = S0;
d.SoilMoistEffectRH.pBGME   = S0(:,1);