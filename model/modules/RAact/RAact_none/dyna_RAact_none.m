function [f,fe,fx,s,d,p] = RAact_none(f,fe,fx,s,d,p,info,tix)
zix = info.tem.model.variables.states.c.zix.cVeg;
s.cd.cEcoEfflux(:,zix)    = 0;
end
