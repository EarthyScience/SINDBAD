function [fx,s,d]=Interception_simple(f,fe,fx,s,d,p,info,i);

%is precomputed


%update the available water
d.WBdum(:,i)=d.WBdum(:,i)-fx.EvapInt(:,i);

end