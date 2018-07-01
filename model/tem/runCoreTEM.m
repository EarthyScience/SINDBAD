function [f,fe,fx,s,d,p] = runCoreTEM(f,fe,fx,s,d,p,info,doPrecOnce,doCore,doSpinUp)

tstart = tic;

%% ------------------------------------------------------------------------
% get the handles for core and precOnce
% -------------------------------------------------------------------------
%--> check if the coreTEM is to be run in spinup mode or forward run
if doSpinUp
    fn{1}   =   'spinup';
else
    fn{1}   =   'model';
end
%--> check if the generated code of the raw code is to be run
if info.tem.model.flags.runGenCode	
    fn{2}	=   'genMS';
else
    fn{2}	=   'rawMS';
end
%--> get the appropriate function handles of precomputation and coreTEM from the above two options

%--> run the handles
if doPrecOnce 
    hPrec               =   info.tem.(fn{1}).code.(fn{2}).precOnce.funHandle;
    [f,fe,fx,s,d,p]     =   hPrec(f,fe,fx,s,d,p,info); 
end
if doCore
    hCore               =   info.tem.(fn{1}).code.(fn{2}).coreTEM.funHandle;
    [f,fe,fx,s,d,p]     =   hCore(f,fe,fx,s,d,p,info); 
end
% disp(['    TIME : runCoreTEM : end : inputs : ' num2str([doPrecOnce,doCore,doSpinUp],'%1.0f|') ' : time : ' sec2som(toc(tstart))])
disp(['    TIME : runCoreTEM with [ doPrecOnce=' num2str(doPrecOnce) ' | doCore = ' num2str(doCore) ' | doSpinUp = ' num2str(doSpinUp) ' ]: ' sec2som(toc(tstart))])



end

%{
if info.flags.runGenCode % using the generated code
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
%}
