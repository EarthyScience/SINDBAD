function [fx,s,d]=RunoffInfE_none(f,fe,fx,s,d,p,info,i);

%this is a dummy
fx.Qinf(:,i) = zeros(info.forcing.size);
%di.watervariable=di.watervariable-fxi.Qinf;
end