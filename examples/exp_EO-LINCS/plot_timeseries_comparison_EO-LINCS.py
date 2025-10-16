import os
import numpy as np
import xarray as xr
import pandas as pd
import zarr
import extraUtils as xu
from matplotlib.gridspec import GridSpec
import matplotlib.pyplot as plt
import string
from collections import OrderedDict

import pickle
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


forcings = dict(cruj=['CRUJRA.v2_2', '1901', '2019'],
                crun=['CRUNCEP.v8', '1901', '2016'] , 
                erai=['ERAinterim.v2', '1979', '2017'])

fn_versions="FLUXNET2015 LaThuile".split(" ")
fn_versions="FLUXNET2015".split(" ")
temp_reso ='daily'
forc_order = ['erai']
# forc_order = ['erai','cruj']


# progno_fc_CN-Qia_FLUXNET_cEco
varibs = {
    "eco_respiration": {
        "obs": "RECO_NT",
        "QC": "RECO_QC_NT_merged",
        "obs_scalar": 1,
        "allow_neg": False,
        "name": "RECO",
        "metric_data": ["reco", ("NNSE", "MSE")]
    },
    "fAPAR": {
        "obs": "NDVI_MCD43A",
        "QC": "NEE_QC_merged",
        "obs_scalar": 1,
        "allow_neg": True,
        "name": "fAPAR",
        "metric_data": ["ndvi", ("NNSE", "MSE")]
    },
    "nee": {
        "obs": "NEE",
        "QC": "NEE_QC_merged",
        "obs_scalar": 1,
        "allow_neg": True,
        "name": "NEE",
        "metric_data": ["nee", ("NNSE", "MSE")]
    },
    "gpp": {
        "obs": "GPP_NT",
        "QC": "GPP_QC_NT_merged",
        "obs_scalar": 1,
        "allow_neg": False,
        "name": "GPP",
        "metric_data": ["gpp", ("NNSE", "MSE")]
    },
    "evapotranspiration": {
        "obs": "LE",
        "QC": "LE_QC_merged",
        "obs_scalar": 0.4081632653,
        "allow_neg": False,
        "name": "ET",
        "metric_data": ["evapotranspiration", ("NNSE", "MSE")]
    },
    "transpiration": {
        "obs": "T_NT_TEA",
        "QC": "GPP_QC_NT_merged",
        "obs_scalar": 1,
        "allow_neg": False,
        "name": "T",
        "metric_data": ["transpiration", ("NNSE", "MSE")]
    },
    "aboveground_biomass": {
        "obs": "agb_merged_PFT",
        "QC": "none",
        "obs_scalar": 1,
        "allow_neg": False,
        "name": "AGB",
        "metric_data": ["agb", ("NMAE1R",)]
    }
}


syear_sim=1979
eyear_sim=2017
date_range = pd.date_range(start=f"{syear_sim}-01-01", end=f"{eyear_sim}-12-31", freq="D")
# Define the two date strings you want to find the indices for

fnrscolo='#18A15C'
fncolo='#FDB311'
rscolo = '#C76A7D'
_vlist = 'nee gpp eco_respiration evapotranspiration transpiration fAPAR aboveground_biomass'.split()
_freq= 'day'
site_stop = 205

overwrite_figs = False
overwrite_figs = True
# span_to_obs_only = True
span_to_obs_only = False


# ssets_dict = OrderedDict([('NSE_set3', ('FN', fncolo)), ('NSE_set1', ('FNRS', fnrscolo))]) # for RS comparisons
ssets_dict = OrderedDict([('ndvi_modis', ('MODIS', fnrscolo)), ('ndvi_sen2', ('Sentinel-2', fncolo))]) # for complete RS comparisons
# ssets_dict = OrderedDict([('NSE_set1', ('O_NSE', '#33CCFF')), ('NNSE_set1', ('O_NNSE', '#FF9933'))]) # for Metric comparisons

ssets = list(ssets_dict.keys())

cmpname = "_v_".join(ssets)
run_name = 'EO-LINCS_v202510'


print(ssets)
if not span_to_obs_only:
    syear_sel = '2000'
    eyear_sel = '2017'

    # Convert date strings to datetime
    start_date = pd.to_datetime(f"{syear_sel}-01-01")
    end_date = pd.to_datetime(f"{eyear_sel}-12-31")

    # Get the indices of the two dates
    start_index = date_range.get_loc(start_date)
    end_index = date_range.get_loc(end_date)

    tspan = np.arange(start_index, end_index + 1)
    fig_d_period = f'{syear_sel}_{eyear_sel}'
else:
    fig_d_period = 'obs_period'

with open("./tmp_metrics_summary/metrics_summary.pkl", "rb") as f:
    # List all datasets inside the file
    data_met = pickle.load(f)

site_list = data_met['sites']
# site_list = ['DE-Hai', 'FR-Pue', ]#'US-Var', 'US-Wkg', 'IT-Ren', 'IT-Cpz', 'US-Seg', 'US-Sne', 'US-MMS', 'US-MMS']
for forcing in forc_order:

    # infile = "/Net/Groups/BGI/scratch/skoirala/RnD/SINDBAD-RnD-SK/examples/data/fluxnet_cube/FLUXNET_v2023_12_1D.zarr"
    # in_data = zarr.open(infile, mode='r')
    # in_variables = list(in_data.keys())
    forname= forcings[forcing][0]
    syear = int(forcings[forcing][1])
    eyear = int(forcings[forcing][2])
    for version in fn_versions:
        for site_index, site in enumerate(site_list):
            infile = os.path.join("/Users/skoirala/research/RnD/SINDBAD-RnD-SK/examples/exp_EO-LINCS/tmp_mergedData/", f"{site}.merged.nc")
            in_data = xr.open_dataset(infile, mode='r')
            in_variables = list(in_data.keys())
            # print(in_data)
            print("--------------------------------\nSite:  ", site)
            set_names=[]
            opt_names=[]
            modfiles=[]
            set_labels=[]
            set_colors=[]
            for sset in ssets:
                # print(sset)
                set_name = sset
# EO-LINCS_v202510_erai_ndvi_sen2_FR-Pue_aboveground_biomass.nc
                modfile = f'/Users/skoirala/research/RnD/SINDBAD-RnD-SK/examples/exp_EO-LINCS/output_{site}_{run_name}_{forcing}_{set_name}/data/{run_name}_{forcing}_{set_name}_{site}_all_variables.nc'
                set_label = ssets_dict[sset][0]
                set_color = ssets_dict[sset][1]
                set_names.append(set_name)
                # opt_names.append(opt_name)
                modfiles.append(modfile)
                set_labels.append(set_label)
                set_colors.append(set_color)
            for _mod in modfiles:
                print(_mod)
            outDirf = f'./tmp_time_series_{cmpname}_{fig_d_period}'
            os.makedirs(outDirf, exist_ok=True)
            fig_file = os.path.join(outDirf, f'{site}_{forname}_{version}_{cmpname}_{fig_d_period}.png')
            if not os.path.exists(fig_file):
                todraw = True
            elif os.path.exists(fig_file) and overwrite_figs:
                todraw = True
            else:
                todraw = False
            # print(todraw, fig_file, os.path.exists(fig_file), overwrite_figs)
            # kera
            if todraw:
                fig=plt.figure(figsize=(9, 15))
                plt.subplots_adjust(hspace=0.5, wspace=0.2)
                spn=1
                # _vlist = list(varibs.keys())
                for _var in _vlist:
                    obs_dats = []
                    obs_v_name = varibs[_var]["obs"]
                    obs_scalar = varibs[_var]["obs_scalar"]
                    if _var == "fAPAR":
                        obs_v_name = "NDVI"
                        obs_dat = in_data[obs_v_name][:]
                        obs = obs_dat.values.flatten() * obs_scalar
                        obs_dats.append(obs)
                        obs_v_name = "NDVI_MCD43A"
                        obs_dat = in_data[obs_v_name][:]
                        obs = obs_dat.values.flatten() * obs_scalar
                        obs_dats.append(obs)
                    else:
                        obs_dat = in_data[obs_v_name][:]
                        obs = obs_dat.values.flatten() * obs_scalar
                        if f'{varibs[_var]["QC"]}' in in_variables:
                            qc_var = in_data[f'{varibs[_var]["QC"]}'][:].values.flatten()                     
                        else:
                            qc_var = np.ones_like(obs)
                            print(f'No QC variable found for {varibs[_var]["QC"]}, proceeding without QC filtering')
                        obs[qc_var<0.85] = np.nan
                        if varibs[_var]["allow_neg"] == False:
                            obs[obs<0] = np.nan
                    obs_dats.append(obs)

                    # obs_v_name = varibs[_var]["obs"]
                    # obs_dat = in_data[obs_v_name][:]
                    # obs = obs_dat.values.flatten() * \
                    #     varibs[_var]["obs_scalar"]
                    # if f'{varibs[_var]["QC"]}' in in_variables:
                    #     qc_var = in_data[f'{varibs[_var]["QC"]}'][:].values.flatten()                     
                    # else:
                    #     qc_var = np.ones_like(obs)
                    # obs[qc_var<0.85] = np.nan
                    # if varibs[_var]["allow_neg"] == False:
                    #     obs[obs<0] = np.nan

                    # print("geraa",obs)
                    mod_dats = []
                    for _mod in modfiles:
                        mod_ds = xr.open_dataset(_mod.replace("all_variables", _var))[_var]
                        var_units = mod_ds.units
                        mod_dats.append(mod_ds.values.flatten())
                    

                    _varI = _vlist.index(_var)
                    # plt.subplot(6,2,spn)


                    # Apply tspan to arrays

                    if _var == "fAPAR":
                        # obs = obs - np.nanmean(obs)
                        obs_dats = [obs - np.nanmean(obs) for obs in obs_dats]

                        for i, mod in enumerate(mod_dats):
                            mod_dats[i] = mod - np.nanmean(mod)

                    # Find indices of non-NaN values
                    if span_to_obs_only:
                        non_nan_index = np.where(~np.isnan(obs))[0]

                        # Determine tspan based on non-NaN entries
                        if len(non_nan_index) < 2:
                            tspan = np.arange(len(obs))
                        else:
                            tspan = np.arange(non_nan_index[0], non_nan_index[-1] + 1)

                    obs = obs[tspan]
                    for i, mod in enumerate(mod_dats):
                        mod_dats[i] = mod[tspan]
                    time_x = date_range[tspan]
                    print(site,':::',_var,obs.shape, time_x.shape)
                    
                    if 'MSC' in _freq:
                        fig=plt.figure(figsize=(8, 2))


                    gs = GridSpec(len(_vlist), 3, figure=fig)
                    ax1 = fig.add_subplot(gs[_varI, :2])
                    xu.rem_axLine()
                    # identical to ax1 = plt.subplot(gs.new_subplotspec((0, 0), colspan=3))
                    if _var == "aboveground_biomass":
                        m_args = {'marker':"o", 'markersize':4, "mfc":'None'}
                    else:
                        m_args = {}

                    for i, mod in enumerate(mod_dats):
                        set_label = set_labels[i]
                        set_color = set_colors[i]
                        plt.plot(time_x, mod, color=set_color, lw=0.56, label=set_label)
                    # if _var == "fAPAR":
                    #     for i, obs in enumerate(obs_dats):
                    #         if i == 0:
                    #             plt.plot(time_x, obs, '#888888', linestyle=(0, (5, 6)), lw=0.7, label='Obs MODIS', **m_args)
                    #         else:
                    #             plt.plot(time_x, obs, '#444444', linestyle=(0, (5, 6)), lw=0.7, label='Obs SEN2', **m_args)
                    # else:
                    if _var != "fAPAR":
                        plt.plot(time_x, obs, '#888888', linestyle=(0, (5, 6)), lw=0.7, label='Obs', **m_args)
                    else:
                        plt.plot(date_range[tspan], obs_dats[0][tspan], ssets_dict["ndvi_sen2"][1], linestyle=(0, (5, 6)), lw=0.7, label='Obs Sentinel 2', **m_args)
                        plt.plot(date_range[tspan], obs_dats[1][tspan], ssets_dict["ndvi_modis"][1], linestyle=(0, (5, 6)), lw=0.7, label='Obs MODIS', **m_args)
                        # 
                    # plt.plot(time_x, obs, '#888888', linestyle=(0, (5, 6)), lw=0.7, label='Obs', **m_args)

                    plt.xlim(time_x[0], time_x[-1])

                    plt.axhline(y=0, lw=0.5, ls='--',color='#cccccc',zorder=1)
                    
                    if _varI == 0:
                        xu.draw_line_legend(_loc='best')
                    plt.ylabel(varibs[_var]["name"] + '\n'+var_units)
                    if _varI == len(_vlist) -1:
                        plt.xlabel('Year')

                    # try:
                    m_data = varibs[_var]["metric_data"]
                    m_var = m_data[0]
                    m_names = m_data[1]
                    tit_base = f"Met.({', '.join(set_labels)}):"
                    tit_s = []
                    for m_name in m_names:
                        tit_s_m = f'{m_name} = '
                        met_s = []
                        for i, set_name in enumerate(set_names):
                            # print(list(data_met.keys()))
                            # kera
                            if _var == "fAPAR":
                                m_var = set_name
                                # print(set_names[i])
                            met_ric = round(data_met[set_name][m_var][m_name][site_index], 2)
                            set_label = set_labels[i]
                            met_ric = "No Obs" if np.isnan(met_ric) else met_ric
                            met_s.append(f'{met_ric}')
                            print(f'{m_var}::::: {set_label}: {m_name} : {site_index} :: {data_met[set_name][m_var][m_name][site_index]} ::: {set_name}= ', met_ric)
                        tit_s_m += f"({', '.join(met_s)})"
                        tit_s.append(tit_s_m)
                    tit_s =  f"{tit_base} {' | '.join(tit_s)}"
                    # except Exception as e:
                        # print(e)
                        # tit_s = ''
                        
                    plt.title(f'{string.ascii_letters[_varI]}) {tit_s}', x=0.053283, y=0.98413849, fontsize=9, ha='left')

                    ax2 = fig.add_subplot(gs[_varI, 2])
                    xu.rem_axLine()
                    ms=4
                    if _var == "aboveground_biomass":
                        ms=10

                    for i, mod in enumerate(mod_dats):
                        set_label = set_labels[i]
                        set_color = set_colors[i]
                        # plt.scatter(mod, obs, marker='o', facecolor=set_color, linewidths=0.,edgecolors=None,alpha=0.3, s=ms, label=set_label)
                        if _var != "fAPAR":
                            plt.scatter(mod, obs, marker='o', facecolor=set_color, linewidths=0.,edgecolors=None,alpha=0.3,s=ms,label=set_label)
                            if _varI == 0:
                                xu.draw_line_legend(_loc='best')
                        else:
                            if set_label == "MODIS":
                                plt.scatter(mod, obs_dats[1][tspan], marker='^', facecolor=set_color, linewidths=0.,edgecolors=None,alpha=0.3, s=ms, label='MODIS')
                            else:
                                plt.scatter(mod, obs_dats[0][tspan], marker='o', facecolor=set_color, linewidths=0.,edgecolors=None,alpha=0.3, s=ms, label='Sentinel')
                            # xu.draw_line_legend(_loc='best')

                    if _varI == 0:
                        xu.draw_line_legend(_loc='best')

                    if _varI == len(_vlist) -1:
                        plt.xlabel('Sim')
                        plt.ylabel('Obs')
                    plt.gca().yaxis.set_label_position("right")
                    xmin, xmax = plt.gca().get_xlim()
                    ymin, ymax = plt.gca().get_ylim()
                    ax_max = max(xmax,ymax)
                    ax_min = min(xmin,ymin)
                    plt.xlim(ax_min, ax_max)
                    plt.ylim(ax_min, ax_max)
                    plt.plot([ax_min, ax_max], [ax_min, ax_max], color='#cccccc', ls='--', lw=0.5,zorder=0)
                    plt.axhline(y=0, lw=0.5, ls='--',color='#cccccc',zorder=1)
                    plt.axvline(x=0, lw=0.5, ls='--',color='#cccccc',zorder=1)
                    xu.put_ticks()
                plt.savefig(fig_file, dpi=350, bbox_inches='tight')
                plt.close()
                if site_index > site_stop:
                    break
            else:
                print(f'Either {site} is already plotted and overwrite_figs = {overwrite_figs} or the files are not existent, infile: {infile}:: {os.path.exists(infile)}, modfile: {modfile}:: {os.path.exists(modfile)}')
