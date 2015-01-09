function [fe,fx,d,p]=Prec_Interception_simple(f,fe,fx,s,d,p,info)

%interception evaporation is simply the minimum of the fapar dependent
%storage and the rainfall

fx.ECanop = min( repmat( p.Interception.isp ,1,info.forcing.size(2)) .* f.FAPAR , f.Rain );

end