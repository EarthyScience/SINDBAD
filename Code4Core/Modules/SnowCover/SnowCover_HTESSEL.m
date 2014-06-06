function [fx,s,d]=SnowCover_HTESSEL(f,fe,fx,s,d,p,info,i);

%first update the snow pack
s.wSWE(:,i)=s.wSWE(:,i)+f.Snow(:,i);


%suggested by Sujan (after HTESSEL GHM)
%default of p.Snow.CoverParam=15
d.SnowCover.frSnow(:,i)=min(1,s.wSWE(:,i)./p.SnowCover.Param);


end