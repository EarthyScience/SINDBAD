function [fe,fx,d]=Prec_Interception_simple_interceptionEvap(f,fe,fx,s,d,p,info);

%interception evaporation is simply the minimum of the fapar dependent
%storage and the rainfall

fx.ECanop=min(p.Interception.isp.*fi.FAPAR,fi.Rain);

end