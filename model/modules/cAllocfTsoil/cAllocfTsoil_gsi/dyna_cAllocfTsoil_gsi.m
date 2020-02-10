function [f,fe,fx,s,d,p] = dyna_cAllocfTsoil_gsi(f,fe,fx,s,d,p,info,tix)
    fT = d.prev.d_cAllocfTsoil_fT;
    d.cAllocfTsoil.fT(:,tix) =   fT +(d.gppfTair.TempScGPP(:,tix)-fT).*p.cAllocfTsoil.tau;
end