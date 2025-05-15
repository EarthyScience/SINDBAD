import os
import numpy as np
# import ipdb
# import numbers
import sys
import xarray as xr
import pandas as pd
import matplotlib.pyplot as plt
import pprint
pp = pprint.PrettyPrinter(indent=4)
# plt.style.use('dark_background')
# plt.style.use('seaborn-darkgrid')
import pycountry
import pickle
import json

import extraUtils as xu
import perf_metrics as pm

from matplotlib.gridspec import GridSpec

import matplotlib.pyplot as plt

import warnings
warnings.filterwarnings("ignore")

SMALL_SIZE = 8
MEDIUM_SIZE = 10
BIGGER_SIZE = 12

plt.rc('font', size=SMALL_SIZE)          # controls default text sizes
plt.rc('axes', titlesize=SMALL_SIZE)     # fontsize of the axes title
plt.rc('axes', labelsize=MEDIUM_SIZE)    # fontsize of the x and y labels
plt.rc('xtick', labelsize=SMALL_SIZE)    # fontsize of the tick labels
plt.rc('ytick', labelsize=SMALL_SIZE)    # fontsize of the tick labels
plt.rc('legend', fontsize=SMALL_SIZE)    # legend fontsize
plt.rc('figure', titlesize=BIGGER_SIZE)  # fontsize of the figure title


def fix_v_names(_v):
    var_out = []
    ig_combs = ['f.', 'f[', 'fe.', 'fe[']
    if len(_v) > 0:
        if not any([_v.startswith(_igc) for _igc in ig_combs]):
            # print(_v)
            _v = _v.replace("']['", '.')
            _v = _v.replace("']", '')
            _v = _v.replace("['", '.')
            _v = _v.replace('"]["', '.')
            _v = _v.replace('"]', '')
            _v = _v.replace('["', '.')
            # print(_v)
    return _v


def mod_data(m_var, all_vars):
    m_var = fix_v_names(m_var)
    m_parts = m_var.split('.')
    data = all_vars
    for m_p in m_parts:
        data = data[m_p]
    # ipdb.set_trace()
    return(data)


def calc_cost(f, fe, fx, s, d, p, obs, info):
    """
    function to calculate the cost of a model simulation

    Requires:
    - forcing structure so that it is not loaded in every iteration
    - observation structure to calculate cost
    - info

    Purposes:
    - returns the full output of the optimization

    Conventions:
    - always needs forcing and observation
    - the parameter scalers should always be written in pScales field of optimOut
    - other output field names can be different

    Created by:
    - Sujan Koirala (skoirala)

    References:

    Versions:
    - 1.0 on 09.11.2020
    """
    ##
    # get the varaibles to optimize
    VariableNames = info['opti']['constraints']['variableNames']

    # force the multiconstraint/variable cost to return an array when a
    # multiobjective method is run
    multiConstraintMethod = info['opti']['costFun']['multiConstraintMethod']
    if info['opti']['algorithm']['isMultiObj']:
        multiConstraintMethod = 'cat'

    # define cost array
    fullCost = []
    fullMetrics = []

    # get cost metric function handle
    metric_fun = info['opti']['costMetric']['funHandle']

    # loop through the variables
    for varName in VariableNames:
        trimPerc = info['opti']['constraints']['variables'][varName]['costOptions']['trimPerc']
        costMetric = info['opti']['constraints']['variables'][varName]['costOptions']['costMetric']
        aggrOrder = info['opti']['constraints']['variables'][varName]['costOptions']['aggrOrder']
        spatialAggr = info['opti']['constraints']['variables'][varName]['costOptions']['spatialAggr']
        spatialCostAggr = info['opti']['constraints']['variables'][varName]['costOptions']['spatialCostAggr']
        timeAggrFreq = info['opti']['constraints']['variables'][varName]['costOptions']['temporalAggr']
        timeAggrFunc = info['opti']['constraints']['variables'][varName]['costOptions']['temporalAggrFunc']
        timeAggrObs = info['opti']['constraints']['variables'][varName]['costOptions']['temporalAggrObs']
        costWeight = info['opti']['constraints']['variables'][varName]['costOptions']['costWeight']
        areaWeight = info['opti']['constraints']['variables'][varName]['costOptions']['areaWeight']
        quality_bound = info['opti']['constraints']['variables'][varName]['costOptions']['quality_bound']
        data_bound = info['opti']['constraints']['variables'][varName]['costOptions']['data_bound']

        # set the CostMetric to the same size array as the number of pixels.
        # Used when the cost is calculated separately for each pixel using
        # table and rowfun
    #         costMetric     = num2cell(repmat(costMetric,info.tem.helpers.sizes.nPix,1),2);

        if isinstance(spatialCostAggr, numbers.Number):
            spatialCostAggr_per = spatialCostAggr
            spatialCostAggr = 'percentile'

        # get the observation data and it's uncertainty
        # ipdb.set_trace()
        obs_proc = obs[varName]['data']
        obs_unc = obs[varName]['unc']
        if obs_unc is None:
            obs_unc = np.ones_like(obs_proc)

        # get the simulation data and set it to sim_proc. The modelFullVar
        # includes the operators so that any mean/median/extraction can be
        # correctly applied.
        modVar = info['opti']['constraints']['variables'][varName]['modelFullVar']
        sim_proc = mod_data(modVar, locals())

        # do the spatiotemporal agrregation
        if aggrOrder == 'spacetime':
            # space first and time second
            sim_proc, obs_proc, obs_unc = spatial_aggregation(
                sim_proc, obs_proc, obs_unc, spatialAggr)
            sim_proc, obs_proc, obs_unc = temporal_aggregation(
                sim_proc, obs_proc, obs_unc, timeAggrFreq, timeAggrFunc, timeAggrObs, info)

        elif aggrOrder == 'timespace':
            # time first and space second
            sim_proc, obs_proc, obs_unc = temporal_aggregation(
                sim_proc, obs_proc, obs_unc, timeAggrFreq, timeAggrFunc, timeAggrObs, info)

            sim_proc, obs_proc, obs_unc = spatial_aggregation(
                sim_proc, obs_proc, obs_unc, spatialAggr)
        else:
            sys.exit('CRIT : calcCostMultiConstraint : The function does not work for : {aggrOrder} order of space and time aggregation aggregation of data. Use either {spacetime, timespace}.'.format(
                aggrOder=aggrOrder))
        # apply the quality flag and filter data based on observation/user input apply quality flag bounds
        if len(quality_bound) > 1 and obs[varName]['qflag'] is not None:
            obs_flag = obs[varName]['qflag']
            # ipdb.set_trace()
            ndx = np.ma.masked_outside(
                obs_flag, quality_bound[0], quality_bound[1]).mask
            obs_proc[ndx] = np.NaN
            obs_unc[ndx] = np.NaN
            sim_proc[ndx] = np.NaN

        # remove the tail percentiles of observation (across all grids)
        if len(trimPerc) > 1:
            percLow = np.nanpercentile(obs_proc, trimPerc[0])
            percHigh = np.nanpercentile(obs_proc, trimPerc[1])
            ndx = np.ma.masked_outside(obs_proc, percLow, percHigh).mask
            obs_proc[ndx] = np.NaN
            obs_unc[ndx] = np.NaN
            sim_proc[ndx] = np.NaN

        # remove the data outside the given bounds of observation (across all
        # grids)
        if len(data_bound) > 1:
            ndx = np.ma.masked_outside(
                obs_proc, data_bound[0], data_bound[1]).mask
            obs_proc[ndx] = np.NaN
            sim_proc[ndx] = np.NaN

        # apply area weight/grid area and calculate mean. The areaWeight can be
        # 0 for false and 1 for true
        if areaWeight > 0:
            datSizeTime_obs = np.shape(obs_proc)[0]
            datSizeTime_sim = np.shape(sim_proc)[0]
            gridArea_obs = np.tile(
                info['tem']['helpers']['dimension']['space']['areaPix'], (datSizeTime_obs, 1))
            gridArea_sim = np.tile(
                info['tem']['helpers']['dimension']['space']['areaPix'], (datSizeTime_sim, 1))
            obs_proc = obs_proc * gridArea_obs
            obs_unc = obs_unc * gridArea_obs
            sim_proc = sim_proc * gridArea_sim

        # compute costs either for all grid cells or per grid cell with summary
        # statistics as cost
        if spatialCostAggr == 'cat':
            cost = metric_fun(sim_proc.flatten().reshape(-1, 1), obs_proc.flatten(
            ).reshape(-1, 1), obs_unc.flatten().reshape(-1, 1), costMetric)
        elif spatialCostAggr in ('mean', 'median', 'percentile'):
            nPix = info['tem']['helpers']['sizes']['nPix']
            pix_cost = np.ones((nPix)) * np.nan
            for pix in range(nPix):
                pix_cost[pix] = metric_fun(
                    sim_proc[:, pix], obs_proc[:, pix], obs_unc[:, pix], costMetric)

            if spatialCostAggr == 'mean':
                cost = np.nanmean(pix_cost)
            if spatialCostAggr == 'median':
                cost = np.nanmean(pix_cost)
            if spatialCostAggr == 'percentile':
                cost = np.nanpercentile(pix_cost, spatialCostAggr_per)
        else:
            sys.exit('CRIT : calcCostMultiConstraint : The function does not work for : {sca}spatial aggregation of cost. Use either [cat, mean, median, or a numeric value for percentile] for the constraint in the field spatialCostAggr.'.format(
                sca=spatialCostAggr))

        # apply weighht for cost
        cost = cost * costWeight

        # collect the cost
        fullCost = np.append(fullCost, cost)
        fullMetrics = np.append(fullMetrics, costMetric)

    ppd = {}
    ppd['names'] = VariableNames
    ppd['metrics'] = fullMetrics
    ppd['costs'] = fullCost

    if multiConstraintMethod == 'cat':
        cost = fullCost
    elif multiConstraintMethod == 'mult':
        cost = np.prod(fullCost)
    elif multiConstraintMethod == 'sum':
        cost = np.nansum(fullCost)
    elif multiConstraintMethod == 'min':
        cost = np.nanmin(fullCost)
    elif multiConstraintMethod == 'max':
        cost = np.nanmax(fullCost)
    else:
        sys.exit('CRIT : calcCostMultiConstraint : The function does not work for : {mcm} multiConstraintMethod. Use either [cat, min, max, mult, sum].'.format(
            mcm=multiConstraintMethod))

    print('Cost:')
    print('.............................................')
    pp.pprint(pd.DataFrame.from_dict(ppd))
    print('.............................................')
    print('Total:', np.round(cost, 2))
    print('---------------------------------------------')

    return cost


def spatial_aggregation(sim_proc_in, obs_proc_in, obs_unc_in, spatialAggr_in):
    """
    # spatial aggregation function
    """
    if spatialAggr_in == 'cat':
        sim_proc = sim_proc_in
        obs_proc = obs_proc_in
        obs_unc = obs_unc_in
    elif spatialAggr_in == 'mean':
        sim_proc = np.nanmean(sim_proc_in, 1)
        obs_proc = np.nanmean(obs_proc_in, 1)
        obs_unc = np.nanmean(obs_unc_in, 1)
    elif spatialAggr_in == 'sum':
        sim_proc = np.nansum(sim_proc_in, 1)
        obs_proc = np.nansum(obs_proc_in, 1)
        obs_unc = np.nansum(obs_unc_in, 1)
    elif spatialAggr_in == 'median':
        sim_proc = np.nanmedian(sim_proc_in, 1)
        obs_proc = np.nanmedian(obs_proc_in, 1)
        obs_unc = np.nanmedian(obs_unc_in, 1)
    else:
        sys.exit(
            'CRIT : calcCostMultiConstraint : The function does not work for : {saf} spatialAggr (spatial aggregation/operation) of data. Use either [cat, mean, median, sum].'.format(saf=spatialAggr_in))

    return sim_proc, obs_proc, obs_unc


def do_time_operation(_array, _dates, res_key, res_method='np.nanmean'):
    # create a database for aggregating or grouping the data depending on the option
    res_dic = {
        "mean": '',
        "day": '1D',
        "8day": '8D',
        "week": '1W',
        "month": '1M',
        "year": '1Y',

        "8dayAnomaly": '8D',
        "weekAnomaly": '1W',
        "monthAnomaly": '1M',
        "yearAnomaly": '1Y',

        "dayMSC": "dayofyear",
        "weekMSC": "week",
        "monthMSC": "month",

        "dayMSCAnomaly": "dayofyear",
        "weekMSCAnomaly": 'week',
        "monthMSCAnomaly": "month",

        "dayIAV": 'dayofyear',
        "weekIAV": 'week',
        "monthIAV": 'month',

    }

    if res_key not in res_dic:
        print(list(res_dic.keys()))
        sys.exit('CRIT : calcCostMultiConstraint : The temporal aggregation does not work for : {taf_in}. Use one of the above methods.'.format(
            taf_in=res_key))
    if res_key == 'mean':
        return np.nanmean(_array)

    # create dimensions and xarray
    # locs = np.arange(_array.reshape(_array.shape[0],-1))
    da = xr.DataArray(_array, coords=[_dates], dims=["time"])
    # get the sampling or grouping method understood by xarray
    res_freq = res_dic[res_key]

    # groupby month/day/week and then do the mean. This does not work for time period such as 8-day, 3-weeks etc.
    if 'MSC' in res_key:
        daw = da.groupby('time.'+res_freq).reduce(eval(res_method))
    elif 'IAV' in res_key:
        # get temporally aggregated data
        res_freq_f = res_dic[res_key.split('I')[0]]
        daw_f = da.resample(time=res_freq_f).reduce(eval(res_method))
        # get climatology after grouping the aggregated data
        clim = daw_f.groupby('time.'+res_freq).reduce(eval(res_method))
        # remove climatology from aggregated data
        daw = daw_f.groupby('time.'+res_freq) - clim
    else:
        # resample the data to the specified period
        daw = da.resample(time=res_freq).reduce(eval(res_method))
    if "Anomaly" in res_key:  # remove mean if the aggregation has Anomaly
        daw = daw-np.nanmean(daw)
    return daw.values


def get_sites(_dir):
    mod_runs = []
    for ff in os.listdir(_dir):
        if ff.endswith('.json'):
            mod_runs = np.append(mod_runs, ff.split('.json')[0].split('_')[-1])
    print(mod_runs)
    # kera
    return np.sort(mod_runs)

def get_cliff_dirname(fnversion, temp_reso):
    """
    Get the folder structure of cliff input and output based on a simple convention
    """
    if fnversion == 'FLUXNET2015':
        opath = 'BRK15'
    elif fnversion == 'LaThuile':
        opath = 'LTL07'
    else:
        opath = ''

    if temp_reso == 'daily':
        otime = 'DD'
    else:
        otime = 'HR'
    return f'fluxnetBGI2021.{opath}.{otime}'


forcings = dict(cruj=['CRUJRA.v2_2', '1901', '2019'],
                crun=['CRUNCEP.v8', '1901', '2016'] , 
                erai=['ERAinterim.v2', '1979', '2017'])

fn_versions="FLUXNET2015".split(" ")
# fn_versions="FLUXNET2015".split(" ")
temp_reso ='daily'
ind=1
forc_order = ['erai']
# forc_order = ['erai', 'cruj']

syear = 2000
eyear = 2019

# progno_fc_CN-Qia_FLUXNET_cEco
varibs = {
    "cRECO": {
        "obs": "RECO_NT",
        "QC": "RECO_QC_NT_merged",
        "obs_scalar": 1,
        "allow_neg": False
    },
    "agb": {
        "obs": "agb_merged_PFT",
        "QC": "none",
        "obs_scalar": 1,
        "allow_neg": False
    },
    "fAPAR": {
        "obs": "mergedNDVI_MCD43A",
        "QC": "NEE_QC_merged",
        "obs_scalar": 1,
        "allow_neg": True
    },
    "NEE": {
        "obs": "NEE",
        "QC": "NEE_QC_merged",
        "obs_scalar": 1,
        "allow_neg": True
    },
    "gpp": {
        "obs": "GPP_NT",
        "QC": "GPP_QC_NT_merged",
        "obs_scalar": 1,
        "allow_neg": False
    },
    "nirv": {
        "obs": "NIRv_MCD43A",
        "QC": "GPP_QC_NT_merged",
        "obs_scalar": 1,
        "allow_neg": True
    },
    "evapTotal": {
        "obs": "LE",
        "QC": "LE_QC_merged",
        "obs_scalar": 0.4081632653,
        "allow_neg": False
    },
    "tranAct": {
        "obs": "T_NT_TEA",
        "QC": "GPP_QC_NT_merged",
        "obs_scalar": 1,
        "allow_neg": False
    }
}


obsdirM = '/Net/Groups/BGI/scratch/skoirala/v202312_wroasted/fluxNet_0.04_CLIFF'

time_freqs = 'day week'.split()
time_freqs = 'day week month annual dayMSC monthAnomaly'.split()
time_freqs = 'day dayMSC dayIAV month monthIAV'.split()
# time_freqs = 'day dayMSC dayIAV month monthIAV'.split()
time_freqs = 'day'.split()
syear_sel=1979
eyear_sel=2017

exp_sets=[f'set{str(a)}' for a in range(1,11)]
exp_sets=[f'set{str(a)}' for a in [1, 3]]
metrs='r2 mef nmae1r nrmse nmae1 nrmse1 ae nae naer fb'.split()
for forcing in forc_order:
    for version in fn_versions:
        data_met = {}
        for _set in exp_sets:
            data_met[_set]={}
            data_met[_set]['sites']=[]
            data_met[_set]['lat']=[]
            data_met[_set]['lon']=[]
            data_met[_set]['PFT']=[]
            for _tf in time_freqs:
                data_met[_set][_tf]={}
                for _met in metrs:
                    data_met[_set][_tf][_met]={}
                    for _var in varibs.keys():
                        data_met[_set][_tf][_met][_var]=[]
        site_list_path = f"../../fluxnet_sites_info/site_list_{version}.csv"
        site_list = [site.strip() for site in open(site_list_path).readlines()]
        fn_dir = get_cliff_dirname(version,temp_reso)
        for _set in exp_sets:
            moddirM = f'/Net/Groups/BGI/scratch/skoirala/v202312_ml_wroasted/sindbad_processed_sets/{_set}'
            # moddirM = f'/Net/Groups/BGI/scratch/skoirala/sopt_sets_wroasted/sindbad_processed_sets/{_set}'
            for site in site_list:
                forname= forcings[forcing][0]
                syear = int(forcings[forcing][1])
                eyear = int(forcings[forcing][2])
                obsdir = os.path.join(obsdirM,fn_dir,'data', forname,temp_reso)
                infile = os.path.join(obsdir, f'{site}.{syear}.{eyear}.{temp_reso}.nc')
                # AT-Neu_pcmaes_fc_FLUXNET_2000-2019.nc

                moddir = os.path.join(moddirM,fn_dir, forname,'data')
                modfile = os.path.join(moddir, f'{site}.{syear}.{eyear}.{temp_reso}.nc')
                # print(infile, modfile, os.path.exists(infile), os.path.exists(modfile))
                if os.path.exists(infile) and os.path.exists(modfile):
                    moddat = xr.open_dataset(modfile)#.sel(time=slice(syear,eyear))
                    indat = xr.open_dataset(infile)#.sel(time=slice(syear,eyear))
                    indat=indat.loc[dict(time=slice(str(syear_sel), str(eyear_sel)))]
                    moddat=moddat.loc[dict(time=slice(str(syear_sel), str(eyear_sel)))]
                    dates = indat['time'].values
                    data_met[_set]['sites']=np.append(data_met[_set]['sites'],site)
                    data_met[_set]['lat']=np.append(data_met[_set]['lat'],moddat['latitude'].values)
                    data_met[_set]['lon']=np.append(data_met[_set]['lon'],moddat['longitude'].values)
                    data_met[_set]['PFT']=np.append(data_met[_set]['PFT'],indat.attrs['PFT'])
                    for _var in varibs.keys():
                        obs_dat_var = indat[varibs[_var]["obs"]]
                        if _var == "agb":
                            mod_dat_var =  moddat['cEco'][:,1]
                        elif _var == 'nirv':
                            mod_dat_var =  moddat['gpp']
                        else:
                            mod_dat_var =  moddat[_var]

                        obs = obs_dat_var.values.flatten() * \
                            varibs[_var]["obs_scalar"]
                        mod = mod_dat_var.values.flatten()

                        if f'{varibs[_var]["QC"]}' in indat.variables:
                            qc_var = indat[f'{varibs[_var]["QC"]}'].values.flatten()                     
                        else:
                            qc_var = np.ones_like(obs)
                        obs[qc_var<0.85] = np.nan
                        if varibs[_var]["allow_neg"] == False:
                            obs[obs<0] = np.nan
                        mod[np.isnan(obs)] = np.nan
                        if _var == "fAPAR":
                            obs = obs - np.nanmean(obs)
                            mod = mod - np.nanmean(mod)
                        if _var == "nirv":
                            obs = obs - np.nanmean(obs)
                            mod = mod - np.nanmean(mod)

                        for _freq in time_freqs:
                            mod_tmp = mod.copy()
                            # mod_tmp[np.isnan(obs)] = np.nan
        
                            if _freq == 'day':
                                obs_t = obs#.values
                                mod_t = mod_tmp#.values
                            else:
                                obs_t = do_time_operation(obs, dates, _freq)
                                mod_t = do_time_operation(mod_tmp, dates, _freq)
                            for metr in metrs:
                                try:
                                    met_v=pm.calc_metric(obs_t,mod_t,np.ones_like(mod_t),metr)
                                except:
                                    met_v=np.nan
                                print(version,'-', _set, '::',site,':::',_freq,'|',_var,'|', metr, '::',met_v)
                                data_met[_set][_freq][metr][_var]=np.append(data_met[_set][_freq][metr][_var],met_v)
                            print('.............................................')

                    moddat.close()
                    indat.close()
                    print('--------------------------------------------------')
        os.makedirs("perf_summary_wroasted_sets", exist_ok=True)
        with open(f'perf_summary_wroasted_sets/performance_summary_{forname}_{version}.pkl'.format(forname=forname, version=version), "wb") as tf:
            pickle.dump(data_met,tf)                    
