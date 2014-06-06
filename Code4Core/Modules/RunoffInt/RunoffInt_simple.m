function [fx,s,d]=RunoffInt_simple(f,fe,fx,s,d,p,info,i);


%simply assume that a fraction of the still available water runs off
fx.Qint(:,i)=p.RunoffInt.rc.*d.WBdum(:,i);
d.WBdum(:,i)=d.WBdum(:,i)-fx.Qint(:,i);
end