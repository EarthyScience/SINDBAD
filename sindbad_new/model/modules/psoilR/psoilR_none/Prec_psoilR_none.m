function [fe,fx,d,p] = prec_psoilR_none(f,fe,fx,s,d,p,info)

% AWC       : maximum plant available water content in the top layer [mm]
%           (p.psoilR.AWC(i).value)

% number of layers
N     = numel(p.psoilR.HeightLayer);

% total soil depth
tSLDP = zeros(info.forcing.size(1),1);
for ij = 1:N
    tSLDP	= tSLDP + p.psoilR.HeightLayer(ij).value;
end

% distribute tAWC equaly according to the soil depth
for ij = 1:N
    p.psoilR.AWC(ij).value    = p.psoilR.tAWC .* p.psoilR.HeightLayer(ij).value ./ tSLDP ;
end

end % function