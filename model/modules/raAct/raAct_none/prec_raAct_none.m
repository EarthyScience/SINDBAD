function [f,fe,fx,s,d,p] = prec_raAct_none(f,fe,fx,s,d,p,info,tix)
% sets the outflow from all vegetation pools to zeros
zix = info.tem.model.variables.states.c.zix.cVeg;
s.cd.cEcoEfflux(:,zix)    = 0;
end
