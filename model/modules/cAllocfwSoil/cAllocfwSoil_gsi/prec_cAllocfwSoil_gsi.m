function [f,fe,fx,s,d,p] = prec_cAllocfwSoil_gsi(f,fe,fx,s,d,p,info)
    
    % computation for the moisture effect on decomposition/mineralization
    d.cAllocfwSoil.fW(:,1) =  1;
end