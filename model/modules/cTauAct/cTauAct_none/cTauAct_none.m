function [f,fe,fx,s,d,p] = cTauAct_none(f,fe,fx,s,d,p,info,tix)
    % set the actual tau to ones
    s.cd.p_cTauAct_k = info.tem.helpers.arrays.onespixzix.c.cEco;
end %function
