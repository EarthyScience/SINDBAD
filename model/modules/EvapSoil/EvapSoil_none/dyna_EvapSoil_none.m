function [f,fe,fx,s,d,p] = dyna_EvapSoil_none(f,fe,fx,s,d,p,info,tix)
fx.EvapSoil(:,tix)    = info.helper.zeros2d;
s.w.wSoil       = s.w.wSoil - fx.EvapSoil;
end