function [f,fe,fx,s,d,p] = prec_cTaufpSoil_none(f,fe,fx,s,d,p,info)
    % Set soil texture effects to ones;
    s.cd.p_cTaufpSoil_kfSoil = info.tem.helpers.arrays.onespixzix.c.cEco;
    % (ineficient, should be pix zix_mic)
end %function
