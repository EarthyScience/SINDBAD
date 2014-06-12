function [fe,fx,d,p]=Prec_SoilEvap_simple_PETsoil(f,fe,fx,s,d,p,info);

fe.PETsoil = f.PET .* p.SoilEvap.alpha .* (1 - f.FAPAR );

end