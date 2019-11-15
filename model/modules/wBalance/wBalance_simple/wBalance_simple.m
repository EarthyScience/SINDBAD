function [f,fe,fx,s,d,p] = wBalance_simple(f,fe,fx,s,d,p,info,tix)
precip=fe.rainSnow.rain(:,tix);
if isfield(fe.rainSnow,'snow')
    precip=precip+fe.rainSnow.snow(:,tix);
end

%dS
dS=s.wd.wTWS-s.prev.s_wd_wTWS;

d.wBalance.WP = precip-fx.Q(:,tix)-fx.ET(:,tix)-dS;
end
