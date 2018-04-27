function [f,fe,fx,s,d,p] = RAact_dummy(f,fe,fx,s,d,p,info,tix)
zix = info.tem.model.variables.states.c.zix.cVeg;
s.cd.cEcoEfflux(:,zix)	= 0;
end % function
