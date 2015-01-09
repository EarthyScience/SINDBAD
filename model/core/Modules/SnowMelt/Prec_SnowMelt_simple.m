function [fe,fx,d,p]=Prec_SnowMelt_simple_snowmeltterm(f,fe,fx,s,d,p,info)

fe.snowmeltterm = max( repmat( p.SnowMelt.Rate ,1,info.forcing.size(2)) .* f.Tair ,0);

end