function [fx,s,d]=Interception_Gash(f,fe,fx,s,d,p,info,i);

%is precomputed

%update the available water
d.Temp.WBdum(:,i) = d.Temp.WBdum(:,i) - fx.ECanop(:,i);

end