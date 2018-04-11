function [fx,s,d,f] = dyna_EvapSoil_none(f,fe,fx,s,d,p,info,tix)
fx.ESoil    = info.helper.zeros2d;
s.w.wSoil       = info.helper.zeros1d;
end