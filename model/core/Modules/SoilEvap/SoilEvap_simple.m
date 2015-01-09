function [fx,s,d]=SoilEvap_simple(f,fe,fx,s,d,p,info,i);

%multiply equilibrium PET with alphaSoil and (1-fapar)
%PET_soil = f.PET(:,i) .* p.SoilEvap.alpha .* (1 - f.FAPAR(:,i) );

%scale the potential with the moisture status and take the minimum of what
%is available
fx.ESoil(:,i) = min( fe.PETsoil(:,i) .* s.wSM1(:,i) ./ p.SOIL.AWC1 , s.wSM1(:,i) );

%update soil moisture of upper layer
s.wSM1(:,i) = s.wSM1(:,i) - fx.ESoil(:,i);


end