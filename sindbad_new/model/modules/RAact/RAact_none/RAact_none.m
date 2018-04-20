function [f,fe,fx,s,d,p] = RAact_none(f,fe,fx,s,d,p,info,tix)
zix = info.tem.model.variables.states.c.cVeg.zix;
s.cd.cEcoEfflux(:,zix)	= 0;
end % function
