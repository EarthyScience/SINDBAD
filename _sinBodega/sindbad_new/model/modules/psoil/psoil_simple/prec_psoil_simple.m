function [f,fe,fx,s,d,p] = prec_psoil_none(f,fe,fx,s,d,p,info)

% AWC       : maximum plant available water content in the top layer [mm]
%           (p.psoil.AWC(zix).value)

% number of layers
N     = numel(p.psoil.HeightLayer);

% total soil depth
tSLDP = zeros(info.forcing.size(1),1);
for ij = 1:N
    tSLDP	= tSLDP + p.psoil.HeightLayer(ij).value;
end

% distribute tAWC equaly according to the soil depth
for ij = 1:N
    p.psoil.AWC(ij).value    = p.psoil.tAWC .* p.psoil.HeightLayer(ij).value ./ tSLDP ;
end

end % function