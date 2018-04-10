function [fe,fx,d,p] = Prec_SOIL_none(f,fe,fx,s,d,p,info)

% AWC       : maximum plant available water content in the top layer [mm]
%           (p.SOIL.AWC(i).value)

% number of layers
N     = numel(p.SOIL.HeightLayer);

% total soil depth
tSLDP = zeros(info.forcing.size(1),1);
for ij = 1:N
    tSLDP	= tSLDP + p.SOIL.HeightLayer(ij).value;
end

% distribute tAWC equaly according to the soil depth
for ij = 1:N
    p.SOIL.AWC(ij).value    = p.SOIL.tAWC .* p.SOIL.HeightLayer(ij).value ./ tSLDP ;
end

end % function