function [f,fe,fx,s,d,p] = dyna_evapSoil_none(f,fe,fx,s,d,p,info,tix)
fx.evapSoil(:,tix)    = info.helper.zeros2d;
s.w.wSoil       = s.w.wSoil - fx.evapSoil;
end