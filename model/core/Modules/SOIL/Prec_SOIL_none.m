function [fe,fx,d,p] = Prec_SOIL_none(f,fe,fx,s,d,p,info)


% AWC1      : maximum plant available water content in the top layer [mm]
%           (p.SOIL.AWC1)
% AWC2      : maximum plant available water content in the bottom layer [mm]
%           (p.SOIL.AWC2)


p.SOIL.AWC1	    = p.SOIL.AWC .* p.SOIL.Depth1;
p.SOIL.AWC2	    = p.SOIL.AWC .* p.SOIL.Depth2;
p.SOIL.AWC12    = p.SOIL.AWC1 + p.SOIL.AWC2;

end % function