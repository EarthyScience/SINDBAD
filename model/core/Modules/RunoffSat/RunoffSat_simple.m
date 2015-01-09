function [fx,s,d]=RunoffSat_simple(f,fe,fx,s,d,p,info,i);

%this is a dummy
fx.Qsat(:,i) = d.Temp.WBdum(:,i) .* d.SaturatedFraction.frSat(:,i);


d.Temp.WBdum(:,i) = d.Temp.WBdum(:,i) - fx.Qsat(:,i);
end