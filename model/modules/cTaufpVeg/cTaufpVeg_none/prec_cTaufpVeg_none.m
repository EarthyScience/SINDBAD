function [f,fe,fx,s,d,p] = prec_cTaufpVeg_none(f,fe,fx,s,d,p,info)
    % set the outputs to ones
    s.cd.p_cTaufpVeg_kfVeg = info.tem.helpers.arrays.onespixzix.c.cEco;
    s.cd.p_cTaufpVeg_LITC2N = info.tem.helpers.arrays.zerospix;
    s.cd.p_cTaufpVeg_LIGNIN = info.tem.helpers.arrays.zerospix;
    s.cd.p_cTaufpVeg_MTF = info.tem.helpers.arrays.onespix;
    s.cd.p_cTaufpVeg_SCLIGNIN = info.tem.helpers.arrays.zerospix;
    s.cd.p_cTaufpVeg_LIGEFF = info.tem.helpers.arrays.zerospix;
end %function
