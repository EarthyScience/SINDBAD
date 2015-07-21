function [fx,s,d,fe,p]=RunModel(f,fe,fx,s,d,p,info,DoPrecO,DoCore,Use4SpinUp)


%DoPrecO: logical flag if the PrecompOnce should be done; if set to 0 then
%fe,fx,d,p is assumed to contain the precomputations from a previous run

%DoCore: logical flag is the core should be run

%Use4SpinUp: logical flag that if set to 1 then only the AutoResp and
%CCycle are being run


if Use4SpinUp
    myCore=info.code.msi.coreSpinUp;
    myPrec=info.code.msi.preCompSpinUp;
else
    myCore=info.code.msi.core;
    myPrec=info.code.msi.preComp;
end


%

if info.flags.runGenCode
    
    if DoPrecO
        [fe,fx,d,p]    = myPrec(f,fe,fx,s,d,p,info);
    end
    
    if DoCore
        [fx,s,d]    = myCore(f,fe,fx,s,d,p,info);
    end
    
    
else
    %use handles
    if DoPrecO
        
        if Use4SpinUp
            sstr={'Prec_AutoResp_ATC_A','Prec_AutoResp_ATC_B','Prec_AutoResp_ATC_C','Prec_CCycle_CASA'};
            for prc = 1:numel(info.code.preComp)
                if info.code.preComp(prc).doAlways == 0
                    
                    tf=strcmp(info.code.preComp(prc).funName,sstr);
                    if max(tf)==1
                        
                        [fe,fx,d,p] = info.code.preComp(prc).fun(f,fe,fx,s,d,p,info);
                    end
                end
            end
            
            
        else
            
            %do precompo
            for prc = 1:numel(info.code.preComp)
                if info.code.preComp(prc).doAlways == 0
                    [fe,fx,d,p] = info.code.preComp(prc).fun(f,fe,fx,s,d,p,info);
                end
            end
            
        end
        
        
    end
    
    if DoCore
        if Use4SpinUp
            for ii = 1:infoSpin.forcing.size(2)
                [fx,s,d]    = infoSpin.code.ms.AutoResp.fun(f,fe,fx,s,d,p,info,ii);
                [fx,s,d]    = infoSpin.code.ms.CCycle.fun(f,fe,fx,s,d,p,info,ii);
            end
        else
            
            [fx,s,d]    = core(f,fe,fx,s,d,p,info);
        end
    end
    
    
    
end

end