function [fx,s,d]=Sublimation_GLEAM(f,fe,fx,s,d,p,info,i);


%PTterm=(fei.Delta./(fei.Delta+fei.Gamma))./fei.Lambda
%Then sublimation (mm/day) is calculated in GLEAM using a P.T. equation
fx.Subl(:,i) = max(0,fe.PTtermSub(:,i).*f.Rn(:,i).*d.SaturatedFraction.frSat(:,i));

%update the snow pack
s.wSWE(:,i)=s.wSWE(:,i)-fx.Subl(:,i);

end