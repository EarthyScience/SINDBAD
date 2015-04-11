function [fe,fx,d,p] = Prec_SOIL_Saxton(f,fe,fx,s,d,p,info)

% AWC       : maximum plant available water content in the top layer [mm]
%           (p.SOIL.AWC(i).value)

% we are assuming here that texture does not change with depth
Alpha       = calc_soilm_prms(p.SOIL.CLAY, p.SOIL.SAND, [], 'alpha');
Beta        = calc_soilm_prms(p.SOIL.CLAY, p.SOIL.SAND, [], 'beta');

% number of layers
N           = numel(p.SOIL.HeightLayer);

% maximuma available water content per layer
p.SOIL.AWC	= struct('value',{});

tAWC        = zeros(info.forcing.size(1),1);
tWPT        = zeros(info.forcing.size(1),1);
tFC         = zeros(info.forcing.size(1),1);
for ij = 1:N
    WPT                     = calc_soilm_prms(p.SOIL.CLAY, p.SOIL.SAND, p.SOIL.HeightLayer(ij).value, 'wpt');
    FC                      = calc_soilm_prms(p.SOIL.CLAY, p.SOIL.SAND, p.SOIL.HeightLayer(ij).value, 'fc');
    AWC                     = FC - WPT;
    p.SOIL.AWC(ij).value    = AWC;
    tAWC                    = tAWC + AWC;
    tWPT                    = tWPT + WPT;
    tFC                     = tFC + FC;
end

p.SOIL.Alpha    = Alpha;
p.SOIL.Beta     = Beta;
p.SOIL.WPT      = tWPT;
p.SOIL.FC       = tFC;
p.SOIL.tAWC     = tAWC;

end % function