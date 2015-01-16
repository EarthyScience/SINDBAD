function [fx,s,d]=SupplyTransp_Federer(f,fe,fx,s,d,p,info,i);

% wSM1      : soil moisture of top layer [mm]
%           (s.wSM1)
% wSM2      : soil moisture of bottom layer [mm]
%           (s.wSM2)


d.SupplyTransp.TranspS(:,i) = p.SupplyTransp.maxRate .* ( s.wSM1(:,i) + s.wSM2(:,i) ) ./ ( p.SOIL.AWC );

end