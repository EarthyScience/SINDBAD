function [WBcheckFlag,WBvioFrac] = CheckWaterBalance(f,fe,fx,s,d,p,info)
%Checks Water Balance

%initialise
WBcheckFlag=NaN;
WBvioFrac=NaN;

%assumes that water pools are stored in d.statesOut
if info.checks.WB
    %precision
    preci = 1E-5;
    
    %sum inputs:
    I = f.Rain + f.Snow;
    
    %sum outputs
    O = fx.ECanop + fx.ESoil + fx.Transp + fx.Qb + fx.Qinf + fx.Qint + fx.Qsat;
    
    %sum pools
    S = d.statesOut.wGW + d.statesOut.wSWE + d.statesOut.wSM;
    
    %calc diff
    dS = diff(S,1,2);
    
    %subset I and O
    I = I(:,1:end-1);
    O = O(:,1:end-1);
    
    WB = abs(I - O - dS);
    
    WBCheck = WB > preci;
    
    WBvioFrac = sum(sum(double(WBCheck)))/numel(WBCheck);
    
    if WBvioFrac ==0
        WBcheckFlag = 1;
    else
        WBcheckFlag =0;
        mmsg=['Water balance not closed in ' num2str(WBvioFrac*100) ' % of cases'];
        warning(mmsg);
    end
end
end

