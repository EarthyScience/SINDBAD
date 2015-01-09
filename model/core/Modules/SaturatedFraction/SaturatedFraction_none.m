function [fx,s,d]=SaturatedFraction_none(f,fe,fx,s,d,p,info,i);

%this is a dummy
d.SaturatedFraction.frSat(:,i) = zeros(info.forcing.size(1),1);
end