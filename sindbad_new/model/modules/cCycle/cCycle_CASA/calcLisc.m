function [fe] = calcLisc(f,fe,fx,s,d,p,info)
% #########################################################################
% FUNCTION	: calcLisc
% 
% PURPOSE	: compute the seasonal cycle of litter fall and root litter
%           "fall" based on LAI variations. Necessarily in precomputation
%           mode...
% 
% REFERENCES:
% Potter, C. S., J. T. Randerson, C. B. Field, P. A. Matson, P. M.
% Vitousek, H. A. Mooney, and S. A. Klooster. 1993.  Terrestrial ecosystem
% production: A process model based on global satellite and surface data. 
% Global Biogeochemical Cycles. 7: 811-841. 
% 
% CONTACT	: Nuno
% 
% INPUT
% lai           : leaf area index (m2/m2)
%               (f.LAI)
% maxMinLAI     : parameter for the maximum value for the minimum LAI
%               (m2/m2)
%               (p.cCycle.maxMinLAI)
% kRTLAI        : parameter for the constant fraction of root litter imputs
%               to the soil ([])
%               (p.cCycle.kRTLAI)
% stepsPerYear	: number of time steps per year
%               (info.timeScale.stepsPerYear)
% NYears        : number of years of simulations
%               (info.timeScale.nYears)
% 
% OUTPUT
% LTLAI         : litter scalar ([])
%               (fe.cCycle.LTLAI)
% RTLAI         : root litter scalar ([])
%               (fe.cCycle.RTLAI)
% #########################################################################

% PARAMETERS
maxMinLAI	= p.cCycle.maxMinLAI;
kRTLAI      = p.cCycle.kRTLAI;

% NUMBER OF TIME STEPS PER YEAR, AND TIME RECORDS
TSPY	= info.timeScale.stepsPerYear;
NYears	= info.timeScale.nYears;

% make sure TSPY is integer
if rem(TSPY,1)~=0,TSPY=floor(TSPY);end

% get LAI
LAI	= f.LAI;

% BUILD AN ANNUAL LAI MATRIX
LAI13                   = zeros(size(LAI,1), TSPY + 1);
LAI13(:, 2:TSPY + 1)	= flipdim(LAI(:,1:TSPY), 2);
LAI13(:, 1)             = LAI(:, 1);

% OUTPUTS
fe.cCycle.LTLAI	= zeros(size(LAI));
fe.cCycle.RTLAI	= zeros(size(LAI));

% TIME COUNTER
k       = 0;
yVec	= unique(f.Year);
for iY = 1:NYears
    TSPYiY	= TSPY + isleapyear(yVec(iY));
    for iS = 1:TSPYiY
        % INCREMENT TIME COUNTER
        k 	= k + 1;
        
        % GET THIS TIME STEP'S LAI
        mLAI	= LAI(:,k);
        
        % FEED LAI13
        LAI13(:, 2:TSPY + 1) = LAI13 (:, 1:TSPY); 
        LAI13(:, 1) = mLAI;

        % CALCULATE DELTA LAI SUM
        dLAIsum                 = LAI13(:, 2:TSPY + 1) - LAI13(:, 1:TSPY);
        dLAIsum(dLAIsum < 0)	= 0;
        dLAIsum                 = sum(dLAIsum, 2);

        % CALCULATE LAI AVERAGE AND MINIMUM
        LAIave                      = mean(LAI13(:, 2:TSPY + 1), 2);
        LAImin                      = min(LAI13(:, 2:TSPY + 1), [], 2);
        LAImin(LAImin > maxMinLAI)	= maxMinLAI(LAImin > maxMinLAI);
        LAIsum                      = sum(LAI13(:, 2:TSPY + 1), 2);

        % CALCULATE LTCON: CONSTANT FRACTION OF LAI
        LTCON       = zeros(size(LAI13(:, 1)));
        ndx         = (LAIave > 0);
        LTCON(ndx)  = LAImin(ndx) ./ LAIave(ndx);

        % CALCULATE dLAI (VARIABLE LAI)
        dLAI            = LAI13(:, 2) - LAI13(:, 1);
        dLAI(dLAI < 0)	= 0;

        % CALCULATE LTVAR: VARIABLE FRACTION OF LAI
        LTVAR                           = zeros(size(dLAI));
        LTVAR(dLAI <= 0 | dLAIsum <= 0)	= 0;
        ndx                             = (dLAI > 0 | dLAIsum > 0);
        LTVAR(ndx)                      = (dLAI(ndx) ./ dLAIsum(ndx));

        % LITTER SCALAR
        LTLAI   = LTCON ./ TSPY + (1 - LTCON) .* LTVAR;

        % ROOT LITTER SCALAR
        RTLAI       = zeros(size(LTLAI));
        ndx         = (LAIsum > 0);
        LAI131st    = LAI13(:, 1);
        RTLAI(ndx)	= (1 - kRTLAI) .* (LTLAI(ndx) + LAI131st(ndx) ./ ...
                    LAIsum(ndx)) ./ 2 + kRTLAI ./ TSPY;

        % FEED OUTPUTS
        fe.cCycle.LTLAI(:,k)	= LTLAI; % leaf litter scalar
        fe.cCycle.RTLAI(:,k)	= RTLAI; % root litter scalar

    end 
end

end % function