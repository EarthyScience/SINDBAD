function X = perfMetric(Obs, Pre, parameter, UncSigma, varargin)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% CALCULATE CALIBRATION AND VALIDATION PARAMETERS.
% X = calc_cvp(Obs, Est, parameter)
%
% X         : parameter
% Obs       : observations (vector)
% Pre       : predictions (vector)
% parameter : measurement to calculate;
%             options   : AVERAGE LEVEL COMPARISON
%                       . 'ae'      : AVERAGE ERROR
%                       . 'nae'     : NORMALIZED AVERAGE ERROR
%                       . 'fb'      : FRACTIONAL MEAN BIAS
%                       . 'rb'      : RELATIVE MEAN BIAS
%                       : POPULATION LEVEL COMPARISON
%                       . 'fv'      : FRACTIONAL VARIANCE
%                       . 'vr'      : VARIANCE RATIO
%                       . 'ks'      : KOLMOGOROV-SMIRNOV
%                       . 'sr'      : SIGNRANK STATISTIC
%                       : INDIVIDUAL LEVEL COMPARISON
%                       : outlier sensitivity
%                       . 'rmse'    : ROOT MEAN SQUARE ERROR
%                       . 'nrmse'   : NORMALIZED ROOT MEAN SQUARE ERROR
%                       . 'ioa'     : INDEX OF AGREEMENT
%                       : absolute value sense analysis
%                       . 'mae'     : MEAN ABSOLUTE ERROR
%                       . 'nmae'    : NORMALIZED MEAN ABSOLUTE ERROR
%                       : absolute error analysis
%                       . 'maxae'   : MAXIMUM ABSOLUTE ERROR
%                       . 'medae'   : MEDIAN ABSOLUTE ERROR
%                       . 'uppae'   : PERCENTILE 75 ABSOLUTE ERROR
%                       : NOMINAL OR BENCHMARK ANALYSIS
%                       . 'rs'      : RATIO OF SCATTER
%                       . 'me'      : MODEL EFFICIENCY (or 'mef')
%                       . 'ns'      : NASH SUTCLIFFE (= MODEL EFFICIENCY)
%                       : LINEAR REGRESSION PARAMETERS
%                       . 'r'       : PEARSON CORRELATION COEFFICIENT
%                       . 'r2'      : r^2
%                       . 'alpha'   : DEGREE OF CONFIDENCE -> CONFIDENCE
%                                     LEVEL OF 100*(1 - alpha)%
%                       : entropy and friends
%                       . 'mic'     : maximal information coefficient
%
% optional inputs       : 'trim_data', 95 (use the 95% samples closer to
%                       the one to one line
%                       : 'do_alternative'
%                       : 'bootstrapit'
%                       : 'benchmark'
%                       : 'NParams'
%
% REFERENCES:
% Janssen, P. H. M. and Heuberger, P. S. C., Calibration of
% process-oriented models, in Ecological Modelling,  83, 55-66, 1995.
%
% Beven, K. J., Rainfall-Runoff Modelling � The Primer, Wiley, 2000
%
% Nash, J. E., and Sutcliffe, J. V., River flow forecasting through
% conceptual models. I Discussion of principles, in Journal of Hydrology,
% 10, 282-290, 1970.
%
% Quinton, J. N., Reducing predictive uncertainty in model simulations: a
% comparison of two methods using the European Soil Erosion Model
% (EUROSEM), in Catena, 30, 101-117, 1997.
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% Created   : NC [2005-04-18 22:03:48]
% Revised   : NC [2005-11-09 09:40:50]
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%
% ndx         = isnan(Obs) == 1 | isnan(Pre) == 1;
% Obs(ndx)    = [];
% Pre(ndx)    = [];
Obs = Obs{:};
Pre = Pre{:};
parameter = parameter{:};
UncSigma = UncSigma{:};

do_alternative  = 0;
benchmark       = [];
bootstrapit     = 0;
NParams         = 0;
mregress        = 0;
minN            = 3;

% evaluate nargin
if nargin > 4
    for i = 1:(nargin - 3) / 2
        eval([varargin{i * 2 - 1} ' = varargin{' num2str(i * 2) '};']);
    end
end

% check if we are doing multiple regressions

if numel(Obs) == numel(Pre)
    if size(Obs, 1) ~= size(Pre, 1)
        Pre = Pre';
    end
end



warning off MATLAB:divideByZero
if numel(Obs) ~= numel(Pre), error('Inputs do not have the same size'), end
if size(Obs)  ~= size(Pre),  Pre = Pre'; end

% check NaNs ??????
usekciY    = 0;
if exist('kci_Y','var')
    if ~isempty(kci_Y)
        usekciY = 1;
    end
end
if usekciY
    ndx         = (isnan(Obs) | isnan(Pre) | isnan(kci_Y) | isinf(Obs) | isinf(Pre) | isinf(kci_Y));
    Obs(ndx)    = [];
    Pre(ndx)    = [];
    kci_Y(ndx)  = [];
    UncSigma(ndx)   =[];
else
    ndx         = (isnan(Obs) | isnan(Pre) | isinf(Obs) | isinf(Pre));
    Obs(ndx)    = [];
    Pre(ndx)    = [];
    UncSigma(ndx)   = [];
    if exist('r_w','var')
        if ~isempty(r_w)
            r_w(ndx)    = [];
        end
    else
        r_w=[];
    end
end


if numel(Obs) < minN
    X = NaN;
    if strcmpi(parameter,'msepart')
        X    = [NaN NaN NaN];
    end
    return
end

if ~isempty(benchmark)
    benchmark(ndx)    = [];
end

parameter   = lower(parameter);

if numel(Obs) <= 3 && strcmpi(parameter,'r'), X = NaN; return, end

% CALCULATE WITH ALTERNATIVE CODE?
if do_alternative
    X    = calc_cvp2(Obs, Pre, parameter);
    return
end


switch parameter
    case lower('SquaredDifferencesVector')
        X    = ((Obs - Pre) .^ 2) ./ UncSigma .^2;
    case lower('AbsoluteDifferencesVector')
        X    = abs(Obs - Pre) ./ abs(UncSigma);
    case lower('dObsdPre')
        %         tic
        dObs    = NaN(numel(Obs)*numel(Obs),1);
        dPre    = dObs;
        k       = 0;
        for j = 1:numel(Obs)
            for i = j+1:numel(Obs)
                k       = k + 1;
                dObs(k)    = Obs(i)-Obs(j);
                dPre(k)    = Pre(i)-Pre(j);
            end
        end
        X    = prctile(dObs ./ dPre,50);
        %         toc
    case 'n'
        X    = numel(Obs);
        
        % AVERAGE LEVEL COMPARISON
    case {'ae', 'nae', 'fb', 'rb'}
        mP = mean(Pre);
        mO = mean(Obs);
        sO = std(Obs);
        
        switch parameter
            case 'ae'   % AVERAGE ERROR
                X = mP - mO;
                
            case 'nae'  % NORMALIZED AVERAGE ERROR
                X = (mP - mO) ./ mO;
                
            case 'fb'   % FRACTIONAL MEAN BIAS
                X = 2 * (mP - mO) ./ (mP + mO);
                
            case 'rb'   % RELATIVE MEAN BIAS
                X = (mP - mO) ./ sO;
        end
        
        % POPULATION LEVEL COMPARISON
    case {'fv', 'vr', 'ks', 'sr'}
        vP = var(Pre);
        vO = var(Obs);
        
        switch parameter
            case 'fv'  % FRACTIONAL VARIANCE
                X = 2 .* (vP - vO) ./ (vP + vO);
                
            case 'vr'  % VARIANCE RATIO
                X = vP ./ vO;
                
            case 'ks'  % KOLMOGOROV-SMIRNOV
                X    = kstest2(Obs, Pre);
                
            case 'sr'  % SIGNRANK
                X    = signrank(Pre-Obs);
        end
        
        % INDIVIDUAL LEVEL COMPARISON
    case {'rmse', 'nrmse', 'ioa', 'mae', 'nmae', ...
            'maxae', 'medae', 'uppae'}
        
        SDS    = sum((Pre - Obs) .^ 2);
        N      = length(Pre);
        mO     = mean(Obs);
        Pline  = Pre - mO;
        Oline  = Obs - mO;
        SDSm   = sum((abs(Pline) - abs(Oline)) .^ 2);
        SDA    = sum(abs(Pre - Obs));
        AbEr   = abs(Pre - Obs); % ./ abs(Obs);
        
%         SDSf    = @(P,O) sum((P - O) .^ 2);
%         Nf      = @(P)length(P);
%         mOf     = @(O)mean(O);
%         Plinef  = @(P,O) P - mO;
%         Olinef  = Obs - mO;
%         SDSmf   = sum((abs(Pline) - abs(Oline)) .^ 2);
%         SDAf    = sum(abs(Pre - Obs));
%         AbErf   = abs(Pre - Obs); % ./ abs(Obs);
%         sqr = @(x) x.^2;
        % outlier sensitivity
        switch parameter
            case 'rmse'    % ROOT MEAN SQUARE ERROR
                X = (SDS ./ N) .^ (1 ./ 2);
                
            case 'nrmse'   % NORMALIZED ROOT MEAN SQUARE ERROR
                X = ((SDS ./ N) .^ (1 ./ 2)) ./ mO;
                
            case 'ioa'     % INDEX OF AGREEMENT
                X = 1 - SDS ./ SDSm;
        end
        
        % absolute value sense analysis
        switch parameter
            case 'mae'     % MEAN ABSOLUTE ERROR
                X = SDA ./ N;
                
            case 'nmae'    % NORMALIZED MEAN ABSOLUTE ERROR
                X = (SDA ./ N) ./ mO;
        end
        
        % absolute error analysis
        switch parameter
            case 'maxae'   % MAXIMUM ABSOLUTE ERROR
                X = max(AbEr);
                
            case 'medae'   % MEDIAN ABSOLUTE ERROR
                X = prctile(AbEr, 50);
                
            case 'uppae'   % PERCENTILE 75 ABSOLUTE ERROR
                X = prctile(AbEr, 75);
        end
        
        % NOMINAL OR BENCHMARK ANALYSIS
    case {'rs', 'me', 'meinf', 'ns', 'nsinf', 'mef', 'mefinv'}
        mO = mean(Obs);
        OmO = sum((Obs - mO) .^ 2);
        PsO = sum((Pre - Obs) .^ 2);
        
        switch parameter
            case 'rs'  % RATIO OF SCATTER
                X = OmO ./ PsO;
                
            case {'me', 'mef'}  % MODEL EFFICIENCY
                X = 1 - PsO ./ OmO;
                
            case {'meinf', 'mefinv'}
                X = 1 - (1 - PsO ./ OmO);
                
            case 'ns' % NASH SUTCLIFFE (= MODEL EFFICIENCY)
                % exactly the same as 'me'
                S = numel(Pre);
                D = sum((Obs - Pre) .^ 2) ./ S;
                N = var(Obs, 1);
                X = 1 - D ./ N;
                
            case 'nsinf' % NASH SUTCLIFFE (= MODEL EFFICIENCY)
                % exactly the same as 'me'
                S = numel(Pre);
                D = sum((Obs - Pre) .^ 2) ./ S;
                N = var(Obs, 1);
                X = D ./ N;
        end
        
        % LINEAR REGRESSION PARAMETERS
    case {'r', 'rinv', 'r2', 'r2inv', 'alpha', 'rlo', 'rup', 'adjr2','rw','r2w'}
        warning off MATLAB:divideByZero
        [r, alpha, rlo, rup]   = corrcoef(Obs, Pre);
        
        switch parameter
            case {'rw','r2w'}
                if find(r_w<0,1,'first'),error('weights cannot be negative');end
                if find(isreal(r_w)==0,1,'first'),error('weights must be real');end
                ndx = r_w > 0 & isnan(r_w) == 0;
                Obs = Obs(ndx);
                Pre = Pre(ndx);
                r_w = r_w(ndx);
                X   = weightedcorrs([Obs(:),Pre(:)],r_w(:));
                X   = X(1,2);
                if strcmpi(parameter,'r2w')
                    X    = X.^2;
                end
                
            case 'r'       % PEARSON CORRELATION COEFFICIENT
                X  = r(1, 2);
            case 'rinv'       % PEARSON CORRELATION COEFFICIENT
                X  = 1 - r(1, 2);
                
            case 'r2'      % r^2
                X  = r(1, 2) .^ 2;
            case 'r2inv'
                X  = 1-r(1, 2) .^ 2;

            case 'adjr2'      % r^2
                X  = r(1, 2) .^ 2;
                N     = numel(Obs);
                if ~exist('adjr2P','var')
                    P    = 2;
                else
                    P  = adjr2P;
                end
                X    = 1 - (1 - X) * ((N - 1) / (N - P - 1));
                
            case 'alpha'   % DEGREE OF CONFIDENCE
                X  = alpha(1, 2);
                
                % THESE WERE ADDED ON 20060208
            case 'rlo'      % LOWER CONFIDENCE INTERVAL LIMIT
                [r, alpha, rlo, rup]   = corrcoef(Obs, Pre, 'alpha', 0.01);
                X                      = rlo(1, 2);
                
            case 'rup'      % UPPER CONFIDENCE INTERVAL LIMIT
                [r, alpha, rlo, rup]   = corrcoef(Obs, Pre, 'alpha', 0.01);
                X                      = rup(1, 2);
        end
        warning on MATLAB:divideByZero
        
    case {'rpoly', 'r2poly', 'alphapoly'}
        if ~exist('polyorder','var'),polyorder=1;end
        p       = polyfit(Pre, Obs, polyorder);
        NewObs  = polyval(p,Pre);
        X       = calc_cvp(NewObs,Obs,strrep(parameter,'poly',''));
        
    case {'r_spearman', 'r_kendall', 'alpha_spearman', 'alpha_kendall'}
        n   = strfind(parameter,'_');
        p    = parameter(1:n-1);
        t   = parameter(n+1:end);
        [r, alpha] = corr(Obs(:),Pre(:),'type',t);
        eval(['X = ' p ';'])
        
    case {'slope', 'intercept', 'offset'}
        p   = polyfit(Pre, Obs, 1);
        
        switch parameter
            case 'slope'
                X   = p(1);
            case {'intercept', 'offset'}
                X   = p(2);
        end
        
    case 'robust_slope'
        b    = robustfit(Pre, Obs);
        X    = b(2);
        % from LI & ZHAO 2006 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    case {'hae'}
        X    = numel(Obs) / sum(1 ./ (abs(Pre - Obs)));
        
    case {'gae'}
        X    = exp(1 / numel(Obs) * sum(log(abs(Pre - Obs))));
        % from LI & ZHAO 2006 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        % from Paruelo 1998 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    case {'ubias', 'uslope', 'uerror'}
        OBS     = mean(Obs);
        PRE     = mean(Pre);
        SSPE    = sum((Obs - Pre) .^ 2);
        
        switch parameter
            case 'ubias'
                n    = numel(Obs);
                X    = (n * (OBS - PRE) ^ 2) / SSPE;
            case 'uslope'
                b    = calc_cvp(Obs, Pre, 'slope');
                X    = ((b - 1) ^ 2 * sum((Pre - PRE) .^ 2)) / SSPE;
            case 'uerror'
                b    = calc_cvp(Obs, Pre, 'slope');
                a    = calc_cvp(Obs, Pre, 'intercept');
                Est    = b .* Obs + a;
                X    = sum((Est - Obs) .^ 2) / SSPE;
        end
        % from Paruelo 1998 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        % from Smith and Rose 1995 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    case 'tic' % Theil's inequality coefficient
        X    = ((sum((Pre - Obs) .^ 2)) ^ (1 / 2)) / ...
            ( ...
            ((sum((Pre) .^ 2)) ^ (1 / 2)) ...
            + ...
            ((sum((Obs) .^ 2)) ^ (1 / 2)) ...
            );
        % from Smith and Rose 1995 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        % from Schaefli and Gupta 2007 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    case 'be'
        % get the benchmark
        Ben    = benchmark;
        X    = 1 - sum((Obs - Pre) .^ 2) / sum((Obs - Ben) .^ 2);
        % from Schaefli and Gupta 2007 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        % regress zero for chris <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    case 'regress0'
        if size(Obs, 2) ~= 1,   Obs    = Obs'; end
        if size(Pre, 2) ~= 1,   Pre    = Pre'; end
        X    = [zeros(size(Obs)) Obs];
        y    = Pre;
        c    = y \ X;
        X    =  c(2);
        % regress zero for chris <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
        
        % information criteria from MJ [Burnham and Andersion, 2004] <<<<<<<<<<
    case {'aic', 'aic_c', 'bic'}
        N               = numel(Obs);
        K               = NParams;
        sigma_square    = sum((Obs - Pre) .^ 2) / N;
        switch parameter
            case 'aic'
                X    = N * log(sigma_square) + 2 * K;
            case 'aic_c'
                X    = N * log(sigma_square) + 2 * K + ...
                    (2 * K * (K + 1)) / (N - K - 1);
            case 'bic'
                X    = N * log(sigma_square) + K * log(N);
        end
        % information criteria from MJ [Burnham and Andersion, 2004] <<<<<<<<<<
    case {'msepart'}
        % decomposition of MSE
        % MSE = mean((Pre-Obs)^2)
        MSEt    = nanmean((Pre-Obs).^2);
        % MSE = 2*std(Obs)*std(Pre)*(1-corr(Obs,Pre)+(std(Pre)-std(Obs))^2+(mean(Pre)-mean(Obs))^2
        %       phase                                variance              bias
        MSEphase    = 2*nanstd(Obs,1)*nanstd(Pre,1)*(1-calc_cvp(Obs,Pre,'r'));
        MSEvariance    = (nanstd(Pre,1)-nanstd(Obs,1))^2;
        MSEbias     = (nanmean(Pre)-nanmean(Obs))^2;
        if abs(MSEt - (MSEphase + MSEvariance + MSEbias)) > 1E-6
            X    = [NaN NaN NaN];
            disp('calc_cvp : MSE dec. does not work')
        else
            X    = [MSEphase MSEvariance MSEbias];
        end
        
        % maximal information content
    case {'mic'}
        if ~exist('micalpha','var'),micalpha=0.6;end
        if ~exist('micC','var'),micC=15;end
        X    = mine(Pre,Obs,micalpha,micC);
        X    = X.mic;
        % Kernel-based Conditional Independence test
    case {'kci'}
        % X    = Obs
        % Z = Pre
        % Y = kci_Y
        if ~exist('kci_Y','var'),kci_Y    = [];end
        if ~exist('kci_pars','var'),kci_pars    = [];end
        if ~exist('kci_varout','var'),kci_varout    = 'pval';end
        [pval,stat]    = indtest_kun(Obs(:),Pre(:),kci_Y(:),kci_pars);
        switch lower(kci_varout)
            case 'pval'; X = pval;
            case 'stat'; X = stat;
            otherwise
                error(['Not a known output for KCI : ' kci_varout])
        end
    otherwise
        error(['Not a known parameter measurement: ' parameter])
end

warning on MATLAB:divideByZero

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function result = calc_cvp2(Obs, Pre, parameter)

% copied from markus code

N               = numel(Obs);
ObsMean         = mean(Obs);
PreMean         = mean(Pre);
ObsVar          = var(Obs);
PreVar          = var(Pre);
AbsErr          = abs(Obs - Pre);
SquErr          = AbsErr .* AbsErr;
SSqErr          = sum(SquErr);
sAbsErr         = sum(AbsErr);
SSqCorPre       = sum((Pre - PreMean) .^ 2);
SSqCorObs       = sum((Obs - ObsMean) .^ 2);
SSqCorPreObs    = sum((Pre - ObsMean) .^ 2);

% 'mae'     : MEAN ABSOLUTE ERROR
mae    = mean(AbsErr);

% 'nmae'    : NORMALIZED MEAN ABSOLUTE ERROR
nmae    = mae ./ ObsMean;

% 'maxae'   : MAXIMUM ABSOLUTE ERROR
maxae    = max(AbsErr);

% 'medae'   : MEDIAN ABSOLUTE ERROR
medae   = median(AbsErr);

% 'rs'      : RATIO OF SCATTER
rs    = SSqCorObs ./ SSqCorPreObs;

% 'rmse'    : ROOT MEAN SQUARE ERROR
rmse    = sqrt(SSqErr ./ N);

% 'nrmse'   : NORMALIZED ROOT MEAN SQUARE ERROR
nrmse    = rmse ./ ObsMean;

% 'me'      : MODEL EFFICIENCY (or 'mef')
mef     = 1 - (SSqErr ./ SSqCorObs);

% 'ae'      : AVERAGE ERROR
ae    = mean(Obs - Pre);

% 'nae'     : NORMALIZED AVERAGE ERROR
nae    = ae ./ ObsMean;

% 'sae'     : STANDARDIZED AVERAGE ERROR
sae = nae ./ sqrt(ObsVar);

% 'maxe'    : MAXIMUM ERROR
maxe    = max(Obs - Pre);

% 'mine'    : MINIMUM ERROR
mine    = min(Obs - Pre);

% 'vr'      : VARIANCE RATIO
vr  = PreVar ./ ObsVar;

% 'tc'      : THEILS COEFFICIENT
tc  = SSqErr ./ sum(Obs .* Obs);

% 'ioa'     : INDEX OF AGREEMENT
ioa    = 1 - (SSqErr ./ sum(abs(Pre - ObsMean) + abs(Obs - ObsMean)) .^ 2);

% 'r2'      : CORRELATION COEFFICIENT
r    = corrcoef(Obs, Pre);
r2  = r .^2;

% LINEAR REGRESSION COEFFICIENTS
p       = polyfit(Pre, Obs, 1);
slope    = p(1);
offset  = p(2);

% attribute the parameter
eval(['result = ' parameter ';']);
