function [fe,fx,d,p]=Prec_TempEffectGPP_CASA(f,fe,fx,s,d,p,info);



% % DEFINE TOPT ARRAY
% TOPT = zeros(size(AIRT(:,1)));
% 
% % could this be optimized?
% maxXXX = max(XXX, [], 2);
% 
% for i = 1:prod(size(TOPT))
%     
%     TOPT(i, 1) = mean(AIRT(i, find(XXX(i, :) == maxXXX(i, 1))));
%     if TOPT(i, 1) < 0, TOPT(i, 1) = max(AIRT(i, :));, end
%     
% end
% 
TOPT = repmat( p.TempEffectGPP.ToptCASA ,1,info.Forcing.Size(2));
AIRT = f.TairDay;
    A       = repmat( p.TempEffectGPP.ToptA ,1,info.Forcing.Size(2));    % original = 0.2
    B       = repmat( p.TempEffectGPP.ToptB ,1,info.Forcing.Size(2));       % original = 0.3
% CALCULATE T1: account for effects of temperature stress;
% reflects the empirical observation that plants in very
% cold habitats typically have low maximum rates
% T1 = 0.8 + 0.02 .* TOPT - 0.0005 .* TOPT .^ 2;
T1	= 1;

%     % CALCULATE T2: also to account effects of temperature
%     % stress; reflects the concept that the efficiency of light
%     % utilization should be depressed when plants are growing
%     % at temperatures displaced from their optimum
%     A       = ToptA;    % original = 0.2
%     B       = ToptB;       % original = 0.3
% 
%     % T2C is the result of the response curve when AIRT = TOPT and the response
%     % curve has the value one
%     T2p     = 1 ./ (1 + exp(A .* (-10))) ./ (1 + exp(B .* (- 10)));
%     T2C     = 1 ./ (T1 .* T2p) - 0.015; % 0.015 is a correction for T1*T2 <= 1
%     T2      = T2C ./ (1 + exp(A .* (TOPT - 10 - AIRT))) ./ ...
%             (1 + exp(B .* (- TOPT - 10 + AIRT)));


    
    % FIRST HALF'S RESPONSE
    T2p1    = 1 ./ (1 + exp(A .* (-10))) ./ (1 + exp(A .* (- 10)));
    T2C1    = 1 ./ T2p1;
    T21     = T2C1 ./ (1 + exp(A .* (TOPT - 10 - AIRT))) ./ ...
            (1 + exp(A .* (- TOPT - 10 + AIRT)));
    
    % SECOND HALF'S RESPONSE
    T2p2     = 1 ./ (1 + exp(B .* (-10))) ./ (1 + exp(B .* (- 10)));
    T2C2     = 1 ./ T2p2;
    T22      = T2C2 ./ (1 + exp(B .* (TOPT - 10 - AIRT))) ./ ...
            (1 + exp(B .* (- TOPT - 10 + AIRT)));
    
    % INTEGRATION
    v=AIRT >= TOPT;
    T2       = T21;
    T2(v)    = T22(v);
    
    d.TempEffectGPP.TempScGPP = T2 .* T1;

end