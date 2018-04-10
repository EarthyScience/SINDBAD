function [fx,s,d] = dyna_EvapSoil_none(f,fe,fx,s,d,p,info,tix)
fx.ESoil    = info.helper.zeros2d;
s.wSM       = info.helper.zeros1d;
end