function [f,fe,fx,s,d,p] = dyna_cAllocfwSoil_gsi(f,fe,fx,s,d,p,info,tix)
    
    % computation for the moisture effect on decomposition/mineralization
    fW                       = d.prev.d_cAllocfwSoil_fW;
    d.cAllocfwSoil.fW(:,tix) =  fW+(d.gppfwSoil.SMScGPP(:,tix)-fW).*p.cAllocfwSoil.tau;
end