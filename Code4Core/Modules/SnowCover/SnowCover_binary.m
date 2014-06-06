function [fx,s,d]=SnowCover_binary(f,fe,fx,s,d,p,info,i);

%first update the snow pack
s.wSWE(:,i)=s.wSWE(:,i)+f.Snow(:,i);

%if there is snow snow fraction is 1, otherwise 0
d.SnowCover.frSnow(:,i)=double(s.wSWE(:,i) > 0);


end