function [f,fe,fx,s,d,p] = prec_cTaufTsoil_none(f,fe,fx,s,d,p,info)
    % set the outputs to ones
    fe.cTaufTsoil.fT = info.tem.helpers.arrays.onespixtix;
end
