function [fx,s,d]=RootUptake_TopBottom(f,fe,fx,s,d,p,info,i);

%first depelete the upper layer
ET1 = min( fx.Transp(:,i) , s.wSM1(:,i) );
s.wSM1(:,i) = s.wSM1(:,i) - ET1;
%then ground water that is in the root zone
ET = fx.Transp(:,i) - ET1;
ET1 = min(ET, s.wGWR(:,i) );
s.wGWR(:,i) = s.wGWR(:,i) - ET1;

%then from lower layer
ET=ET-ET1;
s.wSM2(:,i) = s.wSM2(:,i) - ET;

end