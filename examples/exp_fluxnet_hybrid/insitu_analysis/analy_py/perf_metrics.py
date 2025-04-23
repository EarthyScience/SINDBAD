import numpy as np
import scipy.stats as sc_st
import pingouin as pg
import sys

def calc_metric(Obs, Pre, UncSigma, p_metric, varargin=None):
    """
    CALCULATE CALIBRATION AND VALIDATION PARAMETERS.
    X = calc_metric(Obs, Est, p_metric)
    
    X         : p_metric
    Obs       : observations (vector)
    Pre       : predictions (vector)
    p_metric : measurement to calculate
                options   : AVERAGE LEVEL COMPARISON
                          . 'ae'      : AVERAGE ERROR
                          . 'nae'     : NORMALIZED AVERAGE ERROR
                          . 'fb'      : FRACTIONAL MEAN BIAS
                          . 'rb'      : RELATIVE MEAN BIAS
                          : POPULATION LEVEL COMPARISON
                          . 'fv'      : FRACTIONAL VARIANCE
                          . 'vr'      : VARIANCE RATIO
                          . 'ks'      : KOLMOGOROV-SMIRNOV
                          . 'sr'      : SIGNRANK STATISTIC
                          : INDIVIDUAL LEVEL COMPARISON
                          : outlier sensitivity
                          . 'rmse'    : ROOT MEAN SQUARE ERROR
                          . 'nrmse'   : NORMALIZED ROOT MEAN SQUARE ERROR
                          . 'ioa'     : INDEX OF AGREEMENT
                          : absolute value sense analysis
                          . 'mae'     : MEAN ABSOLUTE ERROR
                          . 'nmae'    : NORMALIZED MEAN ABSOLUTE ERROR
                          : absolute error analysis
                          . 'maxae'   : MAXIMUM ABSOLUTE ERROR
                          . 'medae'   : MEDIAN ABSOLUTE ERROR
                          . 'uppae'   : PERCENTILE 75 ABSOLUTE ERROR
                          : NOMINAL OR BENCHMARK ANALYSIS
                          . 'rs'      : RATIO OF SCATTER
                          . 'me'      : MODEL EFFICIENCY (or 'mef')
                          . 'ns'      : NASH SUTCLIFFE (= MODEL EFFICIENCY)
                          : LINEAR REGRESSION PARAMETERS
                          . 'r'       : PEARSON CORRELATION COEFFICIENT
                          . 'r2'      : r**2
                          . 'alpha'   : DEGREE OF CONFIDENCE -> CONFIDENCE
                                        LEVEL OF 100*(1 - alpha)#
                          : entropy and friends
                          . 'mic'     : maximal information coefficient
    
    optional inputs       : 'trim_data', 95 (use the 95# samples closer to
                          the one to one line
                          : 'do_alternative'
                          : 'bootstrapit'
                          : 'benchmark'
                          : 'NParams'
    
    REFERENCES:
    Janssen, P. H. M. and Heuberger, P. S. C., Calibration of
    process-oriented models, in Ecological Modelling,  83, 55-66, 1995.
    
    Beven, K. J., Rainfall-Runoff Modelling � The Primer, Wiley, 2000
    
    Nash, J. E., and Sutcliffe, J. V., River flow forecasting through
    conceptual models. I Discussion of principles, in Journal of Hydrology,
    10, 282-290, 1970.
    
    Quinton, J. N., Reducing predictive uncertainty in model simulations: a
    comparison of two methods using the European Soil Erosion Model
    (EUROSEM), in Catena, 30, 101-117, 1997.

    Created   : NC [2005-04-18 22:03:48]
    Revised   : NC [2005-11-09 09:40:50]
    """
    #
    Obs = Obs
    Pre = Pre
    UncSigma = UncSigma
    p_metric = p_metric

    do_alternative = 0
    benchmark = []
    bootstrapit = 0
    NParams = 0
    mregress = 0
    minN = 3

    # # evaluate nargin
    # if nargin > 4
    #     for i = 1:(nargin - 3) / 2
    #         eval([varargin{i * 2 - 1} ' = varargin{' num2str(i * 2) '}'])
    #     end
    # end

    # check if we are doing multiple regressions
    p_metric = p_metric.lower()
    if np.size(Obs) == np.size(Pre):
        if np.size(Obs, 0) != np.size(Pre, 0):
            Pre = Pre.T

    # warning off MATLAB:divideByZero

    # # check np.nans ??????
    usekciY = 0
    # if exist('kci_Y','var')
    #     if ~isempty(kci_Y)
    #         usekciY = 1
    #     end
    # end
    if usekciY:
        ndx = np.isnan(Obs) * np.isnan(Pre) * np.isnan(kci_Y) * \
                       np.isinf(Obs) or np.isinf(Pre) * np.isinf(kci_Y)
        Obs[ndx] = np.nan
        Pre[ndx] = np.nan
        kci_Y[ndx] = np.nan
        UncSigma[ndx] = np.nan
    else:
        ndx = np.isnan(Obs) * np.isnan(Pre) * np.isinf(Obs) * np.isinf(Pre)
        Obs[ndx] = np.nan
        Pre[ndx] = np.nan
        UncSigma[ndx] = np.nan
        if 'r_w' in locals():
            if len(r_w) > 0:
                r_w[ndx] = np.nan
            else:
                r_w = np.nan

    if np.size(Obs) < minN:
        X = np.nan
        if p_metric == 'msepart':
            X = [np.nan, np.nan, np.nan]
            return X

    X = 0

    if len(benchmark) > 0:
         benchmark[ndx] = []

    if len(Obs) <= 3 and p_metric == 'r':
        X = np.nan
        return X

    if p_metric == 'SquaredDifferencesVector'.lower():
        X = ((Obs - Pre) ** 2) / UncSigma ** 2
    if p_metric == 'AbsoluteDifferencesVector'.lower():
        X = abs(Obs - Pre) / abs(UncSigma)
    if p_metric == 'dObsdPre'.lower():
        dObs = np.ones((len(Obs)*len(Obs), 1)) * np.nan
        dPre = dObs
        k = 0
        for j in range(len(Obs)):
            for i in range(j+1, len(Obs)):
                k = k + 1
                dObs[k] = Obs[i]-Obs[j]
                dPre[k] = Pre[i]-Pre[j]
        X = np.percentile(dObs / dPre, 50)
    if p_metric == 'n':
        X = len(Obs)

    # AVERAGE LEVEL COMPARISON
    if p_metric in ('ae', 'nae', 'naer', 'fb', 'rb'):
        mP = np.nanmean(Pre)
        mO = np.nanmean(Obs)
        sO = np.nanstd(Obs)
        # print(f'metric: {p_metric}, mO: {mO}, mp: {mP}')
        if p_metric == 'ae':    # AVERAGE ERROR
            X = mP - mO

        if p_metric == 'nae':  # NORMALIZED AVERAGE ERROR
            X = (mP - mO) / mO

        if p_metric == 'naer':  # NORMALIZED AVERAGE ERROR
            X = (mP - mO) / mP

        if p_metric == 'fb':   # FRACTIONAL MEAN BIAS
            X = 2 * (mP - mO) / (mP + mO)

        if p_metric == 'rb':   # RELATIVE MEAN BIAS
            X = (mP - mO) / sO

    # POPULATION LEVEL COMPARISON
    if p_metric in ('fv', 'vr', 'ks', 'sr'):
        vP = np.var(Pre)
        vO = np.var(Obs)

        if p_metric == 'fv':  # FRACTIONAL VARIANCE
            X = 2 * (vP - vO) / (vP + vO)

        if p_metric == 'vr':  # VARIANCE RATIO
            X = vP / vO
        if p_metric == 'ks':  # KOLMOGOROV-SMIRNOV
            X = sc_st.ks_2samp(Obs, Pre)
        # SIGNRANK (check if this is the right one: sujan)
        if p_metric == 'sr':
            X = sc_st.wilcoxon(Pre, Obs)

    # INDIVIDUAL LEVEL COMPARISON
    if p_metric in ('rmse', 'nrmse', 'nrmse1', 'ioa', 'mae', 'nmae', 'nmae1r', 'nmae1', 'maxae', 'medae', 'uppae'):
        SDS = np.nansum((Pre - Obs) ** 2)
        N = len(Pre)
        mO = np.nanmean(Obs)
        mPre = np.nanmean(Pre);
        Pline = Pre - mO
        Oline = Obs - mO
        SDSm = np.nansum((np.abs(Pline) - np.abs(Oline)) ** 2)
        SDA = np.nansum(np.abs(Pre - Obs))
        AbEr = np.abs(Pre - Obs)  # / abs(Obs)

        SDSf = lambda P, O: np.nasum((P - O) ** 2)
        Nf = lambda P: len(P)
        mOf = lambda O: np.nanmean(O)
        Plinef = lambda P: P - mO
        Olinef = Obs - mO
        SDSmf = np.nansum((np.abs(Pline) - np.abs(Oline)) ** 2)
        SDAf = np.nansum(np.abs(Pre - Obs))
        AbErf = np.abs(Pre - Obs)  # / abs(Obs)
        sqr = lambda x: x**2
        # outlier sensitivity
        if p_metric == 'rmse':    # ROOT MEAN SQUARE ERROR
            X = (SDS / N) ** (1 / 2)

        if p_metric == 'nrmse':   # NORMALIZED ROOT MEAN SQUARE ERROR
            X = ((SDS / N) ** (1 / 2)) / mO

        if p_metric == 'nrmse1':   # NORMALIZED ROOT MEAN SQUARE ERROR
            X = ((SDS / N) ** (1 / 2)) / (1 + mO)

        if p_metric == 'ioa':     # INDEX OF AGREEMENT
            X = 1 - SDS / SDSm

        # absolute value sense analysis
        if p_metric == 'mae':     # MEAN ABSOLUTE ERROR
            X = SDA / N

        if p_metric == 'nmae':    # NORMALIZED MEAN ABSOLUTE ERROR
            X = (SDA / N) / mO
        if p_metric == 'nmae1':    # NORMALIZED MEAN ABSOLUTE ERROR
            # X = (SDA / N) / (mO + 1)
            X = abs(mO - mPre) / (mO + 1);
        if p_metric == 'nmae1r':    # NORMALIZED MEAN RELATIVE ERROR with adjustment for small value and normalized to model value
            X = abs((SDA / N) / (mPre));

        # absolute error analysis
        if p_metric == 'maxae':   # MAXIMUM ABSOLUTE ERROR
            X = np.nanmax(AbEr)

        if p_metric == 'medae':   # MEDIAN ABSOLUTE ERROR
            X = np.nanpercentile(AbEr, 50)

        if p_metric == 'uppae':   # PERCENTILE 75 ABSOLUTE ERROR
            X = np.nanpercentile(AbEr, 75)

    # NOMINAL OR BENCHMARK ANALYSIS
    if p_metric in ('rs', 'me', 'meinf', 'ns', 'nsinf', 'mef', 'mefinv'):
        mO = np.nanmean(Obs)
        OmO = np.nansum((Obs - mO) ** 2)
        PsO = np.nansum((Pre - Obs) ** 2)

        if p_metric == 'rs':  # RATIO OF SCATTER
            X = OmO / PsO

        if p_metric in ('me', 'mef'):  # MODEL EFFICIENCY
            X = 1 - PsO / OmO

        if p_metric in ('meinf', 'mefinv'):
            X=1 - (1 - PsO / OmO)

        if p_metric == 'ns':  # NASH SUTCLIFFE (= MODEL EFFICIENCY)
            # exactly the same as 'me'
            S=len(Pre)
            D=np.nansum((Obs - Pre) ** 2) / S
            N=np.nanvar(Obs, 1)
            X=1 - D / N

        if p_metric == 'nsinf':  # NASH SUTCLIFFE (= MODEL EFFICIENCY)
            # exactly the same as 'me'
            S=len(Pre)
            D=np.nansum((Obs - Pre) ** 2) / S
            N=np.nanvar(Obs, 1)
            X=D / N

    # LINEAR REGRESSION PARAMETERS
    if p_metric in ('r', 'rinv', 'r2', 'alpha', 'rlo', 'rup', 'adjr2', 'rw', 'r2w'):
        pgr=pg.corr(Obs, Pre)
        r=pgr.r.values[0]
        # r, p=sc_st.pearsonr(Obs, Pre)

        if p_metric in ('rw', 'r2w'):
            sys.error('rw, and r2w are not implemented yet')
    #                 if find(r_w<0,1,'first'),error('weights cannot be negative')end
    #                 if find(isreal(r_w)==0,1,'first'),error('weights must be real')end
    #                 ndx = r_w > 0 & isnan(r_w) == 0
    #                 Obs = Obs[ndx]
    #                 Pre = Pre[ndx]
    #                 r_w = r_w[ndx]
    #                 X   = weightedcorrs([Obs(:),Pre(:)],r_w(:))
    # #                 X   = X(1,2)
    # #                 if strcmpi(p_metric,'r2w')
    # #                     X    = X**2
    # #                 end

        if p_metric == 'r':       # PEARSON CORRELATION COEFFICIENT
            X=r
        if p_metric == 'rinv':       # PEARSON CORRELATION COEFFICIENT
            X=1 - r

        if p_metric == 'r2':      # r**2
            X=r ** 2


    #             case 'adjr2'      # r**2
    #                 X  = r(1, 2) ** 2
    #                 N     = len(Obs)
    #                 if ~exist('adjr2P','var')
    #                     P    = 2
    #                 else
    #                     P  = adjr2P
    #                 end
    #                 X    = 1 - (1 - X) * ((N - 1) / (N - P - 1))

    #             case 'alpha'   # DEGREE OF CONFIDENCE
    #                 X  = alpha(1, 2)

    #                 # THESE WERE ADDED ON 20060208
    #             case 'rlo'      # LOWER CONFIDENCE INTERVAL LIMIT
    #                 [r, alpha, rlo, rup]   = corrcoef(Obs, Pre, 'alpha', 0.01)
    #                 X                      = rlo(1, 2)

    #             case 'rup'      # UPPER CONFIDENCE INTERVAL LIMIT
    #                 [r, alpha, rlo, rup]   = corrcoef(Obs, Pre, 'alpha', 0.01)
    #                 X                      = rup(1, 2)


    if p_metric in ('rpoly', 'r2poly', 'alphapoly'):
        if 'polyorder' not in locals():
            polyorder=1
        # p       = polyfit(Pre, Obs, polyorder)
        # NewObs  = polyval(p,Pre)
        # X       = calc_metric(NewObs,Obs,strrep(p_metric,'poly',''))

    if p_metric in ('r_spearman', 'r_kendall', 'alpha_spearman', 'alpha_kendall'):
        if 'spearman' in p_metric:
            r, p=sc_st.spearmanr(Obs, Pre)
        else:
            r, p=sc_st.kendalltau(Obs, Pre)
        if 'r' in p_metric:
            X=r
        else:
            X=p

    if p_metric in ('slope', 'intercept', 'offset'):
        p=np.polyfit(Pre, Obs, 1)

        if p_metric == 'slope':
            X=p[0]
        else:  # 'intercept', 'offset'
            X=p[1]

    if p_metric == 'robust_slope':
        sys.error("robust_slope not implemented in python")
        # b=robustfit(Pre, Obs)
        X=b[1]
    # from LI & ZHAO 2006 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    if p_metric == 'hae':
        X=len(Obs) / np.nansum(1 / (np.abs(Pre - Obs)))

    if p_metric == 'gae':
        X=np.exp(1 / len(Obs) * np.nansum(np.log(abs(Pre - Obs))))
    # from LI & ZHAO 2006 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    # from Paruelo 1998 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    if p_metric in ('ubias', 'uslope', 'uerror'):
        OBS=np.nanmean(Obs)
        PRE=np.nanmean(Pre)
        SSPE=np.nansum((Obs - Pre) ** 2)
        if p_metric == 'ubias':
            n=len(Obs)
            X=(n * (OBS - PRE) ** 2) / SSPE
        if p_metric == 'uslope':
            b=calc_metric(Obs, Pre, 'slope')
            X=((b - 1) ** 2 * sum((Pre - PRE) ** 2)) / SSPE
        if p_metric == 'uerror':
            b=calc_metric(Obs, Pre, 'slope')
            a=calc_metric(Obs, Pre, 'intercept')
            Est=b * Obs + a
            X=sum((Est - Obs) ** 2) / SSPE
    # from Paruelo 1998 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    # from Smith and Rose 1995 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    if p_metric == 'tic':  # Theil's inequality coefficient
        X=((np.nansum((Pre - Obs) ** 2)) ** (1 / 2)) / (((np.nansum((Pre) ** 2)) ** (1 / 2)) + ((np.nansum((Obs) ** 2)) ** (1 / 2))
            )
    # from Smith and Rose 1995 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    # from Schaefli and Gupta 2007 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    if p_metric == 'be':
        # get the benchmark
        Ben=benchmark
        X=1 - np.nansum((Obs - Pre) ** 2) / np.nansum((Obs - Ben) ** 2)
    # from Schaefli and Gupta 2007 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    # regress zero for chris <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    if p_metric == 'regress0':
        sys.error('regress0: not implemented yet in python')
    #     if size(Obs, 2) ~= 1,   Obs    = Obs'end
    #     if size(Pre, 2) ~= 1,   Pre    = Pre'end
    #     X    = [zeros(size(Obs)) Obs]
    #     y    = Pre
    #     c    = y \ X
    #     X    =  c(2)
    # regress zero for chris <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    # information criteria from MJ [Burnham and Andersion, 2004] <<<<<<<<<<
    if p_metric in ('aic', 'aic_c', 'bic'):
        N=len(Obs)
        K=NParams
        sigma_square=np.nansum((Obs - Pre) ** 2) / N
        if p_metric == 'aic':
            X=N * np.log(sigma_square) + 2 * K
        if p_metric == 'aic_c':
            X=N * np.log(sigma_square) + 2 * K + \
                         (2 * K * (K + 1)) / (N - K - 1)
        if p_metric == 'bic':
            X=N * np.log(sigma_square) + K * np.log(N)
    # information criteria from MJ [Burnham and Andersion, 2004] <<<<<<<<<<
    if p_metric == 'msepart':
        # decomposition of MSE
        # MSE = mean((Pre-Obs)**2)
        MSEt=np.nanmean((Pre-Obs)**2)
        # MSE = 2*std(Obs)*std(Pre)*(1-corr(Obs,Pre)+(std(Pre)-std(Obs))**2+(mean(Pre)-mean(Obs))**2
        #       phase                                variance              bias
        MSEphase=2*np.nanstd(Obs, 1)*np.nanstd(Pre, 1) * \
                             (1-calc_metric(Obs, Pre, 'r'))
        MSEvariance=(np.nanstd(Pre, 1)-np.nanstd(Obs, 1)) ** 2
        MSEbias=(np.nanmean(Pre)-np.nanmean(Obs)) ** 2
        if np.abs(MSEt - (MSEphase + MSEvariance + MSEbias)) > 1e-6:
            X=[np.nan, np.nan, np.nan]
            print('calc_metric : MSE dec. does not work')
        else:
            X=[MSEphase, MSEvariance, MSEbias]

        # maximal information content
    if p_metric == 'mic':
        if 'micalpha' not in locals():
            micalpha=0.6
        if 'micC' not in locals():
            micC=15
        # X    = mine(Pre,Obs,micalpha,micC) # unknown function mine (sujan)
        X=X['mic']
        # Kernel-based Conditional Independence test
    if p_metric == 'kci':
        sys.error('kci not impemeted in python')
        # X=Obs
        # Z=Pre
        # Y=kci_Y

        # if 'kci_Y' not in locals():
        #     kci_Y=[]
        # if 'kci_pars' not in locals():
        #     kci_pars=[]
        # if 'kci_varout' not in locals():
        #     kci_varout='pval'
        #     # pval,stat    = indtest_kun(Obs,Pre,kci_Y,kci_pars) # unknown function (sujan)
        # if kci_varout == 'pval':
        #     X=pval

        # if kci_varout == 'stat':
        #     X=stat
        # else:
        #     sys.exit('Not a known output for KCI : {kciv}'.format(
        #         kciv=kci_varout))

    return X
