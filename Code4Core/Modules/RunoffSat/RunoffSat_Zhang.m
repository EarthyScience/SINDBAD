function [fx,s,d]=RunoffSat_Zhang(f,fe,fx,s,d,p,info,i);

%this is a supply / demand limit concept cf Budyko
%it's conceptually not really consistent with 'saturation runoff'
%calc demand limit (X0)
X0=f.PET(:,i)+(p.SOIL.AWC1+p.SOIL.AWC2-(s.wSM1(:,i)+s.wSM2(:,i)));

%calc supply limit (P) (modified)
P=d.WBdum(:,i);
%p.RunoffSat.alpha default ~0.5

fx.Qsat(:,i)= P - P.*(1+X0./P - ( 1+(X0./P).^(1/p.RunoffSat.alpha) ).^p.RunoffSat.alpha );

d.WBdum(:,i)=d.WBdum(:,i)-fx.Qsat(:,i);

end