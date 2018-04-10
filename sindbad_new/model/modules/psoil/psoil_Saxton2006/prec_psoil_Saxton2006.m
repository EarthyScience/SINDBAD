function [fe,fx,d,p] = prec_psoil_Saxton2006(f,fe,fx,s,d,p,info)

% AWC       : maximum plant available water content in the top layer [mm]
%           (p.psoil.AWC(i).value)

% we are assuming here that texture does not change with depth

% number of layers
N           = numel(p.psoil.HeightLayer);

% maximuma available water content per layer
p.psoil.AWC	= struct('value',{});

tAWC        = zeros(info.forcing.size(1),1);
tWPT        = zeros(info.forcing.size(1),1);
tFC         = zeros(info.forcing.size(1),1);
for ij = 1:N
    info.helper.psoil.layer  = ij;
    [Alpha,Beta,WPT,FC]     = calcSoilmParams(p,info);
    AWC                     = FC - WPT;
    p.psoil.AWC(ij).value    = AWC;
    tAWC                    = tAWC + AWC;
    tWPT                    = tWPT + WPT;
    tFC                     = tFC + FC;
end

p.psoil.Alpha    = Alpha;
p.psoil.Beta     = Beta;
p.psoil.WPT      = tWPT;
p.psoil.FC       = tFC;
p.psoil.tAWC     = tAWC;

end % function