function [fx,s,d]=SnowMelt_simple(f,fe,fx,s,d,p,info,i);

%Then snow melt (mm/day) is calculated as a simple function of temperature
%and scaled with the snow covered fraction
fx.Qsnow(:,i)=min(s.wSWE(:,i),fe.snowmeltterm(:,i).*d.SnowCover.frSnow(:,i));

%update the snow pack
s.wSWE(:,i)=s.wSWE(:,i)-fx.Qsnow(:,i);

%a dummy that tracks how much water is still 'available'
d.WBdum(:,i)=f.Rain(:,i)+fx.Qsnow;

end