function [f,fe,fx,s,d,p] = dyna_EvapTotal_simple(f,fe,fx,s,d,p,info,tix)

    
%%
etComps=info.tem.model.variables.to.sum.ET;

for ws = 1:numel(etComps)
    etComp=etComps{ws};
    if isfield(fx,etComp)
        if info.tem.model.flags.genRedMemCode && ismember(etComp,info.tem.model.code.variables.to.redMem)
            fx.ET(:,tix) = fx.ET(:,tix)  + fx.(etComp);
        else
            fx.ET(:,tix) = fx.ET(:,tix)  + fx.(etComp)(:,tix);
        end
    end    
end
end
