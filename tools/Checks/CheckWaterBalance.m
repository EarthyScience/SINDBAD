function [info] = CheckWaterBalance(f,fe,fx,s,d,p,info)
%Checks Water Balance
%assumes that water pools are stored in d.statesOut

%if info.flags.CheckWBalance
if info.checks.WBalance

    %precision
    preci = 1E-5; % this could be in the info and be the same for all the variables

    %sum inputs:
    if isfield(fe,'Snow')
        I = f.Rain + fe.Snow;
    else
        I = f.Rain + f.Snow;
    end
    %sum outputs
    O = fx.ECanop + fx.ESoil + fx.Transp + fx.Subl + fx.Qb + fx.Qinf + fx.Qint + fx.Qsat;

    %sum pools
	S = d.statesOut.wGWR + d.statesOut.wGW + d.statesOut.wSWE + d.statesOut.wSM;

    %calc diff
    dS = diff(S,1,2);

    %subset I and O
    I = I(:,2:end);
    O = O(:,2:end);

    WB = abs(I - O - dS);

    WBCheck = WB > preci;

    %info.checks.WBVioFrac = sum(sum(double(WBCheck)))/numel(WBCheck);
    WBvioFrac = sum(sum(double(WBCheck)))/numel(WBCheck);

    if WBvioFrac > 0
        %info.flags.WBalanceOK =0;
        mmsg=['Water balance not closed in ' num2str(WBvioFrac*100) ' % of cases'];
        warning(mmsg);
    end

end


end % function

