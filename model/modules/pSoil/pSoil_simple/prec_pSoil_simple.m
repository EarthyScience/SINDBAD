function [f,fe,fx,s,d,p] = prec_pSoil_simple(f,fe,fx,s,d,p,info)

% AWC       : maximum plant available water content in the top layer [mm]
%           (p.pSoil.AWC(zix).value)

% number of layers
N     = numel(p.pSoil.HeightLayer);

% total soil depth
tSLDP = info.tem.helpers.arrays.zerospix;
for ij = 1:N
    tSLDP	= tSLDP + p.pSoil.HeightLayer(ij).value;
end

% distribute tAWC equaly according to the soil depth
for ij = 1:N
    p.pSoil.AWC(ij).value    = p.pSoil.tAWC .* p.pSoil.HeightLayer(ij).value ./ tSLDP ;
end

end % function