function [f,fe,fx,s,d,p] = prec_cAllocfTsoil_gsi(f,fe,fx,s,d,p,info)
    % set to 1 the 1st time step of temperature effect on C allocation
    d.cAllocfTsoil.fT(:,1) =   1;
end