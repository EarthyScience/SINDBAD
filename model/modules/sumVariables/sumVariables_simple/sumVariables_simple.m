function [f,fe,fx,s,d,p] = sumVariables_simple(f,fe,fx,s,d,p,info,tix)

CL=info.tem.model.code.variables.to.sum.codeLines;
for ii  =   1:length(CL)
    sstr            =   char(CL(ii));
    eval(sstr);
end

end % function

