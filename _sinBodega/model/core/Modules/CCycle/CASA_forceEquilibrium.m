function [fx,s,d]  = CASA_forceEquilibrium(f,fe,fx,s,d,p,info)

% CALCULATE NEP
fNEP	= sum(fx.npp,2)-sum(fx.rh,2);

% DISTRIBUTE REMAINING NEP BY THE POOLS: (depends on the doSpinUpFast flag
% SOIL_MIC  12 (old 10)
% SLOW      13 (old 11)
% OLD       14 (old 12)
if info.flags.doSpinUpFast
    % GIVE IT TO THE SLOW; SOIL MICROBIAL, AND OLD POOLS
    K12	= fe.CCycle.kfEnvTs(12).value .* (...
        fe.CCycle.ctransfer(14).xtrEFF .* (1 - fe.CCycle.ctransfer(14).effFLUX) + ...
        fe.CCycle.ctransfer(13).xtrEFF .* (1 - fe.CCycle.ctransfer(13).effFLUX));
    
    K13 = fe.CCycle.kfEnvTs(13).value .* (...
        fe.CCycle.ctransfer(9).xtrEFF .* (1 - fe.CCycle.ctransfer(9).effFLUX) + ...
        fe.CCycle.ctransfer(8).xtrEFF .* (1 - fe.CCycle.ctransfer(8).effFLUX));
    
    K14 = fe.CCycle.kfEnvTs(14).value .* (...
        fe.CCycle.ctransfer(10).xtrEFF .* (1 - fe.CCycle.ctransfer(10).effFLUX));

    
    R12 = sum(fx.cEfflux(12).value, 2);
    R13 = sum(fx.cEfflux(13).value, 2);
    R14 = sum(fx.cEfflux(14).value, 2);
    
    R   = R12 + R13 + R14;
    
    K12 = sum(K12, 2);
    K13 = sum(K13, 2);
    K14 = sum(K14, 2);
    
    C12 = (fNEP .* R12) ./ (K12 .* R);
    C13 = (fNEP .* R13) ./ (K13 .* R);
    C14 = (fNEP .* R14) ./ (K14 .* R);
    
    s.cPools(12).value    = s.cPools(12).value + C12;
    s.cPools(13).value    = s.cPools(13).value + C13;
    s.cPools(14).value    = s.cPools(14).value + C14;
    
else
    % GIVE TO THE OLD POOL
    K14 = fe.CCycle.kfEnvTs(14).value .* (...
        fe.CCycle.ctransfer(10).xtrEFF .* (1 - fe.CCycle.ctransfer(10).effFLUX));
    K14 = sum(K14, 2);
    C14 = fNEP ./ K14;
    
    % FEED THE POOL STRUCTURE
    s.cPools(14).value	= s.cPools(14).value + C14;
end

% make the fx consistent with the pools
for ii = 1:info.forcing.size(2)
%     [fx,s,d]    = info.code.ms.AutoResp.fun(f,fe,fx,s,d,p,info,ii);
    [fx,s,d]    = info.code.ms.CCycle.fun(f,fe,fx,s,d,p,info,ii);
end

end % function
