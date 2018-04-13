function [f,fe,fx,s,d,p] = runCoreTEM(f,fe,fx,s,d,p,info,flagDoPrecOnce,flagDoCore,flagUse4SpinUp)

%% ------------------------------------------------------------------------
% get the handles for core and precOnce
% -------------------------------------------------------------------------
if flagUse4SpinUp,  fn = 'spinup';
else,               fn = 'model';
end
hCore	= info.tem.(fn).code.genMS.coreTEM.funHandle;
hPrec   = info.tem.(fn).code.genMS.precOnce.funHandle;

%% run the core and the precOnce
if info.flags.runGenCode % using the generated code
    if flagDoPrecOnce;  [f,fe,fx,s,d,p]	= hPrec(f,fe,fx,s,d,p,info); end
    if flagDoCore;      [f,fe,fx,s,d,p]	= hCore(f,fe,fx,s,d,p,info); end
else % use the pure handles
    if flagUse4SpinUp
        if flagDoPrecOnce
            sstr	= {'Prec_AutoResp_ATC_A','Prec_AutoResp_ATC_B','Prec_AutoResp_ATC_C','Prec_CCycle_CASA'};
            for prc = 1:numel(info.tem.model.code.prec)
                if~info.tem.model.code.prec(prc).runAlways
                    if sum(strcmp(info.tem.model.code.prec(prc).funName,sstr))>0
                        [f,fe,fx,s,d,p] = info.tem.model.code.prec(prc).funHandle(f,fe,fx,s,d,p,info);
                    end
                end
            end
        end
        if flagDoCore
            sstr = {'RAact','cCycle'};
            for ii = 1:infoSpin.forcing.size(2)
                for m = sstr
                    [f,fe,fx,s,d,p]    = infoSpin.code.ms.(m{1}).funHandle(f,fe,fx,s,d,p,info,ii);
                end
            end
        end
    else %  not in spinup
        if flagDoPrecOnce
            % run the precOnce for all the modules that are not runAlways
            for prc = 1:numel(info.tem.model.code.prec)
                if~info.tem.model.code.prec(prc).runAlways
                    [f,fe,fx,s,d,p] = info.tem.model.code.prec(prc).funHandle(f,fe,fx,s,d,p,info);
                end
            end
        end
        if flagDoCore
            [f,fe,fx,s,d,p]    = info.tem.model.code.coreTEM.funHandle(f,fe,fx,s,d,p,info);
            % it is easier then looping in time looping using info.tem.model.code.ms.(moduleName).funHandle
        end
    end
end

end %  function
