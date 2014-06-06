function [fx,s,d]=SupplyTransp_Federer(f,fe,fx,s,d,p,info,i);

d.SupplyTransp.TranspS(:,i)=p.SupplyTransp.maxRate.*(s.wSM1(:,i)+s.wSM2(:,i))./(p.SOIL.AWC);

end