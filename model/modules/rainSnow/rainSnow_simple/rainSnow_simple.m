function [f,fe,fx,s,d,p] = rainSnow_simple(f,fe,fx,s,d,p,info,tix)

fe.rainSnow.rain(:,tix)=f.Rain(:,tix);
fe.rainSnow.snow(:,tix)=fe.wSnowFrac.Snow(:,tix);

end % function

