function [fe,fx,d,p] = prec_psoilR_Saxton2006(f,fe,fx,s,d,p,info)

% AWC       : maximum plant available water content in the top layer [mm]
%           (p.psoilR.AWC(i).value)

% we are assuming here that texture does not change with depth

% number of layers
N           = numel(p.psoilR.HeightLayer);

% maximuma available water content per layer
p.psoilR.AWC	= struct('value',{});

tAWC        = zeros(info.forcing.size(1),1);
tWPT        = zeros(info.forcing.size(1),1);
tFC         = zeros(info.forcing.size(1),1);
for ij = 1:N
    info.helper.psoilR.layer  = ij;
    [Alpha,Beta,WPT,FC]     = calcSoilmParams(p,info);
    AWC                     = FC - WPT;
    p.psoilR.AWC(ij).value    = AWC;
    tAWC                    = tAWC + AWC;
    tWPT                    = tWPT + WPT;
    tFC                     = tFC + FC;
end

p.psoilR.Alpha    = Alpha;
p.psoilR.Beta     = Beta;
p.psoilR.WPT      = tWPT;
p.psoilR.FC       = tFC;
p.psoilR.tAWC     = tAWC;

end % function