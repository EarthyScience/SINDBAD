function [fe,fx,d,p]=Prec_SoilEvap_simple(f,fe,fx,s,d,p,info);

fe.PETsoil = f.PET .* repmat( p.SoilEvap.alpha ,1,info.forcing.size(2)) .* (1 - f.FAPAR );

end