function [fx,s,d] = evapCsoil_none(f,fe,fx,s,d,p,info,i)
fx.ESoil    = info.helper.zeros2d;
s.wSM       = info.helper.zeros1d;
end