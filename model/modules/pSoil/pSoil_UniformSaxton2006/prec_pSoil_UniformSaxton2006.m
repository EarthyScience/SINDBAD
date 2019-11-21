function [f,fe,fx,s,d,p] = prec_pSoil_UniformSaxton2006(f,fe,fx,s,d,p,info)

% AWC       : maximum plant available water content in the top layer [mm]
%           (p.pSoil.AWC(zix).value)

% we are assuming here that texture does not change with depth

% number of layers
N           = numel(fe.wSoilBase.soilDepths); %sujan
% N           = numel(p.pSoil.HeightLayer);

% maximuma available water content per layer
p.pSoil.AWC	= struct('value',{});

AWC         = info.tem.helpers.arrays.onespixzix.w.wSoil;
tAWC        = info.tem.helpers.arrays.onespixzix.w.wSoil;
tWPT        = info.tem.helpers.arrays.onespixzix.w.wSoil;
tFC         = info.tem.helpers.arrays.onespixzix.w.wSoil;
% tAWC        = info.tem.helpers.arrays.zerospix;
% tWPT        = info.tem.helpers.arrays.zerospix;
% tFC         = info.tem.helpers.arrays.zerospix;
for ij = 1:N
    info.helper.pSoil.layer  = ij;
    [Alpha,Beta,WPT,FC]     = calcSoilParams(p,fe,info);
    AWC                     = (FC - WPT) .* AWC;
%     p.pSoil.AWC(ij).value    = AWC;
    tAWC                    = tAWC + AWC;
    tWPT                    = tWPT + WPT;
    tFC                     = tFC  + FC;
end

p.pSoil.Alpha    = Alpha;
p.pSoil.Beta     = Beta;
p.pSoil.WPT      = tWPT;
p.pSoil.FC       = tFC;
p.pSoil.tAWC     = tAWC;

end % function