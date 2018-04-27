function [f,fe,fx,s,d,p] = runPrecOnceTEM(f,fe,fx,s,d,p,info)
% run the precOnce for all the modules that are not runAlways
for prc = 1:numel(info.tem.model.code.prec)
    if~info.tem.model.code.prec(prc).runAlways
        [f,fe,fx,s,d,p] = info.tem.model.code.prec(prc).funHandle(f,fe,fx,s,d,p,info);
    end
end
end
