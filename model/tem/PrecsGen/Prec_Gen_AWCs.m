function [fe,fx,d,p]=Prec_Gen_AWCs(f,fe,fx,s,d,p,info);


p.SOIL.AWC1 = p.SOIL.AWC .* p.SOIL.Depth1;
p.SOIL.AWC2 = p.SOIL.AWC .* p.SOIL.Depth2;
p.SOIL.AWC12 = p.SOIL.AWC2 + p.SOIL.AWC1;



end