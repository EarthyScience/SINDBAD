function [fx,s,d]=RunoffSat_simple(f,fe,fx,s,d,p,info,i);

%this is a dummy
fx.Qsat(:,i)=d.WBdum(:,i).*d.SaturatedFraction.frSat(:,i);


d.WBdum(:,i)=d.WBdum(:,i)-fx.Qsat(:,i);
end