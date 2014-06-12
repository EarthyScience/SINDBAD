function [fe,fx,d,p]=Prec_Interception_simple_interceptionEvap(f,fe,fx,s,d,p,info);

%interception evaporation is simply the minimum of the fapar dependent
%storage and the rainfall

fx.ECanop = min( p.Interception.isp .* f.FAPAR , f.Rain );

end