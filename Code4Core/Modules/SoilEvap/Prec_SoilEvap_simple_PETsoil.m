function [fe,fx,d,p]=Prec_SoilEvap_simple_PETsoil(f,fe,fx,s,d,p,info);

fe.PETsoil = f.PET .* repmat( p.SoilEvap.alpha ,1,info.Forcing.Size(2)) .* (1 - f.FAPAR );

end