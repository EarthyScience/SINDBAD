function [f,fe,fx,s,d,p] = prec_cTaufLAI_none(f,fe,fx,s,d,p,info)
    % set values to ones
    s.cd.p_cTaufLAI_kfLAI = info.tem.helpers.arrays.onespixzix.c.cEco; %(ineficient, should be pix zix_veg)
end
