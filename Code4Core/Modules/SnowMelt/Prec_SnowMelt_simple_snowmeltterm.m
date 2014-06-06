function [fe,fx,d]=Prec_SnowMelt_simple_snowmeltterm(f,fe,fx,s,d,p,info,i);

fe.snowmeltterm=max(p.SnowMelt.Rate.*f.Tair,0);

end