function [fe,fx,d,p]=Prec_SnowMelt_simple_snowmeltterm(f,fe,fx,s,d,p,info,i);

fe.snowmeltterm = max( p.SnowMelt.Rate .* f.Tair ,0);

end