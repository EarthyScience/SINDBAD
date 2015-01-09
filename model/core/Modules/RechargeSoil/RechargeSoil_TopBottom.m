function [fx,s,d]=RechargeSoil_TopBottom(f,fe,fx,s,d,p,info,i);


%water refill from top to bottom
%upper layer
ip = min( p.SOIL.AWC1 - s.wSM1(:,i) , d.Temp.WBdum(:,1) );
s.wSM1(:,i) = s.wSM1(:,i) + ip;
d.Temp.WBdum(:,1) = d.Temp.WBdum(:,1) - ip;


%lower layer
ip=min( p.SOIL.AWC2 - s.wSM2(:,i) , d.Temp.WBdum(:,1) );
s.wSM2(:,i) = s.wSM2(:,i) + ip;
d.Temp.WBdum(:,1) = d.Temp.WBdum(:,1) - ip;

end