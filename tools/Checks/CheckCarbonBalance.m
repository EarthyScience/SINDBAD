function [info] = CheckCarbonBalance(f,fe,fx,s,d,p,info)
% Checks Carbon Balance
% dC/dT = inputs - outputs

%if info.flags.CheckCBalance
if info.checks.CBalance
    
    %precision
    preci = 1E-5; % this could be in the info and be the same for all the variables

    %sum inputs:
    I = fx.gpp;

    %sum outputs
    O = fx.ra + fx.rh;

    %pools
    S = d.statesOut.cTotal;

    %calc diff
    dS = diff(S,1,2);

    %subset I and O
    I = I(:,2:end);
    O = O(:,2:end);

    CB = abs(I - O - dS);

    CBCheck = CB > preci;

    %info.checks.CBVioFrac = sum(sum(double(CBCheck)))/numel(CBCheck);
    CBvioFrac = sum(sum(double(CBCheck)))/numel(CBCheck);

    if CBvioFrac > 0
        %info.flags.CBalanceOK =0;
        mmsg=['Carbon balance not closed in ' num2str(CBvioFrac*100) ' % of cases'];
        warning(mmsg);
    end

end


end % function