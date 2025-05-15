import os
import numpy as np
# import ipdb
# import numbers
import sys
import pandas as pd
import matplotlib.pyplot as plt
# plt.style.use('dark_background')
# plt.style.use('seaborn-darkgrid')
# import pycountry
import pickle
import json
import matplotlib as mpl
import seaborn as sns
# import ipdb
import extraUtils as xu
# import perf_metrics as pm

from matplotlib.gridspec import GridSpec

import string
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


def get_colomap(cmap_nm,bounds__,lowp=0.05,hip=0.95):
    '''
    Get the list of colors from any official colormaps in mpl. It returns the number of colors based on the number of items in the bounds. Bounds is a list of boundary for each color.
    '''
    cmap__ = mpl.cm.get_cmap(cmap_nm)
    color_listv=np.linspace(lowp,hip,len(bounds__)-1)
    rgba_ = [cmap__(_cv) for _cv in color_listv]
    return(rgba_)

class BoundaryNorm(mpl.colors.Normalize):
    def __init__(self, boundaries):
        self.vmin = boundaries[0]
        self.vmax = boundaries[-1]
        self.boundaries = boundaries
        self.N = len(self.boundaries)

    def __call__(self, x, clip=False):
        x = np.asarray(x)
        ret = np.zeros(x.shape, dtype=np.int)
        for i, b in enumerate(self.boundaries):
            ret[np.greater_equal(x, b)] = i
        ret[np.less(x, self.vmin)] = -1
        ret = np.ma.asarray(ret / float(self.N-1))
        return ret

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


def get_bins(dat, intv):
    bins = np.ones(len(intv)-1) * np.nan
    allcnt=0
    datsize=np.sum(~np.isnan(dat))
    for _int in range(len(intv)-1):
        v1=intv[_int]
        v2=intv[_int+1]
        # print(dat, v1, v2)
        cnt = 0
        for _dat in dat:
            if _dat >= v1 and _dat < v2:
                cnt = cnt + 1
                allcnt = allcnt + 1
        bins[_int] = cnt * 1./ datsize
        # print(np.nansum(bins), v1, v2)
        # dat2=dat[datint]
        # print(len(dat2), len(dat))
        # if len(dat2) > 0:
        #     bins[_int]=len(dat2) * 1./ len(dat)
    bins[bins==0] = np.nan
    # print(intv, allcnt, len(dat), datsize)
    return bins

def draw_vlines(dat, colo):
    q25=round(np.nanpercentile(dat,25),2)
    q50=round(np.nanpercentile(dat,50),2)
    q75=round(np.nanpercentile(dat,75),2)
    tmp1=dat[~np.isnan(dat)]
    lt0 = int((tmp1 < 0).sum()*100/len(tmp1))
    lt05 = int((tmp1 < 0.5).sum()*100/len(tmp1))
    plt.axvline(x=q25,ls=':',lw=0.93,color=colo)
    plt.axvline(x=q50,ls='-',lw=0.93,color=colo)
    plt.axvline(x=q75,ls=':',lw=0.93,color=colo)
    if _met == 'mef':
        txt_m=f'<0: {lt0}%, <0.5: {lt05}% [{q25}, {q50}, {q75}]'
    else:
        txt_m=f'<0.5: {lt05}% [{q25}, {q50}, {q75}]'
    return txt_m


forcings = dict(cruj=['CRUJRA.v2_2', '1901', '2019'],
                crun=['CRUNCEP.v8', '1901', '2016'] , 
                erai=['ERAinterim.v2', '1979', '2017'])

# fn_versions="FLUXNET2015 LaThuile".split(" ")
fn_versions="FLUXNET2015".split(" ")
temp_reso ='daily'
ind=1
# forc_order = ['erai','cruj']
forc_order = ['erai']

syear = 2000
eyear = 2019

# progno_fc_CN-Qia_FLUXNET_cEco
varibs = {
    "cRECO": {
        "name":"Ecosystem Respiration",
        "obs": "RECO_NT",
        "QC": "RECO_QC_NT_merged",
        "obs_scalar": 1
    },
    "fAPAR": {
        "name":"Fraction Absorbed Radiation",
        "obs": "mergedNDVI_MCD43A",
        "QC": "NEE_QC_merged",
        "obs_scalar": 1
    },
    "agb": {
        "name":"Aboveground Biomass",
        "obs": "agb_merged_PFT",
        "QC": "none",
        "obs_scalar": 1
    },
    "NEE": {
        "name":"Net Ecosystem Exchange",
        "obs": "NEE",
        "QC": "NEE_QC_merged",
        "obs_scalar": 1
    },
    "gpp": {
        "name":"Gross Primary Productivity",
        "obs": "GPP_NT",
        "QC": "GPP_QC_NT_merged",
        "obs_scalar": 1
    },
    "evapTotal": {
        "name":"Evapotranspiration",
        "obs": "LE",
        "QC": "LE_QC_merged",
        "obs_scalar": 0.4081632653
    },
    "tranAct": {
        "name":"Transpiration",
        "obs": "T_NT_TEA",
        "QC": "GPP_QC_NT_merged",
        "obs_scalar": 1
    }
}
varib_list = 'NEE gpp cRECO evapTotal tranAct fAPAR agb'.split()
var_names={
    "NEE": ["NEE", 'mef'],
    "gpp": ["GPP", 'mef'],
    "cRECO": ["RECO", 'mef'],
    "evapTotal": ["ET", 'mef'],
    "tranAct": ["T", 'mef'],
    "fAPAR": ["fAPAR", 'mef'],
    "agb": ["AGB", 'nmae1']
}


time_freqs = 'day week'.split()
time_freqs = 'day week month dayMSC monthAnomaly'.split()
time_freqs = 'day'.split()
# time_freqs = 'day dayMSC dayIAV month monthIAV'.split()

metrs='mef r2'.split()
# _freq='day'

import cartopy.crs as crs
import cartopy.feature as cfeature
x0=0.01
y0=0.7
wp=0.33
hp=0.5
ym=0.243
f_dir = './'
os.makedirs(f_dir,exist_ok=True)
site_miss={'FLUXNET2015': ''.split(', '),
'LaThuile': ''.split(', ')}

# clist = get()
# bounds = negb[:-1].tolist() + posb.tolist()

# insig=0.010
# bounds = (np.array([\
#             -1.,-0.9,-0.80,-0.7,-0.60,-0.5, -0.40,-0.3,-0.20,-0.1,\
#             0,\
#             0.1,0.2,0.3,0.4,0.5,0.60, 0.7,0.8,0.9,1.0
#             ])*1).tolist()
_freq = 'day'
ssets = ['set1', 'set3']

for forcing in forc_order:
    forname= forcings[forcing][0]
    for version in fn_versions:
        datplot={}

        for _set in ssets:
            with open(f"perf_summary_wroasted_sets/performance_summary_{forname}_{version}.pkl", "rb") as tf:
                data_met = pickle.load(tf)[_set]
            site_list = data_met['sites']

            datplot[_set]={}
            datplot[_set]['PFT'] = ['UNCL.' if item == 'undefined' else item for item in data_met['PFT']]
            pft = np.sort(list(set(datplot[_set]['PFT'])))
            datplot[_set]['sites'] = data_met['sites']
            if _set == 'set1':
                datplot[_set]['Exp']=['FNRS' for sl in site_list]
            else:
                datplot[_set]['Exp']=['FN' for sl in site_list]
            # plt.suptitle(, x=0.2, y=1.032, color='#888888')
            for _var in varib_list:
                _met = var_names[_var][1]
                _varI = varib_list.index(_var)
                dat = data_met[_freq][_met][_var]
                # dat_t=data_met[_freq][_met]['tranAct']
                # dat[np.isnan(dat_t)]=np.nan
                print(_var)
                if _met == 'mef':
                    dat[dat<-1]=-1
                for sn in range(len(site_list)):
                    if site_list[sn] in site_miss[version]:
                        print(site_list[sn], 'fuck')
                        dat[sn] = np.nan
                datplot[_set][_var] = dat
df1 = pd.DataFrame.from_dict(datplot['set1'])
df2 = pd.DataFrame.from_dict(datplot['set3'])
frames = [df1, df2]


result = pd.concat(frames,ignore_index=True)

# ipdb.set_trace()
pft = ['GRA', 'CRO', 'OSH', 'CSH', 'SAV', 'WSA', 'MF', 'DNF', 'ENF', 'DBF', 'EBF', 'WET', 'UNCL.']
xlabs=[f'{_pft} ({datplot["set1"]["PFT"].count(_pft)})' for _pft in pft]
print(result, pft, xlabs)

# kera
exp_set = {
    "FN": ['NEE gpp cRECO evapTotal tranAct'.split(), 3, 2],
    "FNRS": ['fAPAR agb'.split(), 1, 2]
}


for exp in exp_set.keys():
    exp_info = exp_set[exp]
    varib_list = exp_info[0]
    for forcing in forc_order:
        forname= forcings[forcing][0]
        for version in fn_versions:

            site_list = data_met['sites']
            spn=1
            if exp == 'FN':
                fig = plt.figure(figsize=(8,12.5))
            else:
                fig = plt.figure(figsize=(8,3.6))


            plt.subplots_adjust(hspace=0.4, wspace=0.3)
            for _var in varib_list:
                _met = var_names[_var][1]
                _varI = varib_list.index(_var)
                fnrscolo='#18A15C'
                fncolo='#FDB311'
                # fnrscolo=(24, 161, 92)
                # fncolo=(253, 179, 17)
                res_var =  result[~result[_var].isnull()]
                pft_var = list(res_var['PFT'].to_numpy())
                xlabs=[f'{_pft} ({int(pft_var.count(_pft)/2.0)})' for _pft in pft]
                print(_var, xlabs)
                ax = plt.subplot(exp_info[1],exp_info[2],spn)
                bx = sns.boxplot(x="PFT", y=_var, hue="Exp",order=pft, hue_order = ['FN', 'FNRS'],
                   data=result, dodge=True, fliersize=0, linewidth=0.6, palette={"FN": fncolo, "FNRS": fnrscolo})
        
                # Change the appearance of that box

                for _bx in bx.artists:
                    # _bxI = bx.artists.index(_bx)
                    
                    # if _bxI % 2 == 0:
                    #     c=fncolo
                    #     _bx.set_facecolor(fncolo)
                    # else:
                    #     _bx.set_facecolor(fnrscolo)
                    #     c=fnrscolo

                    _bx.set_linewidth(0)
                    # print(_bxI, pft_var[_bxI], c, result.Exp[_bxI])

                if _met == 'mef':
                    dmin=-1
                    dmax=1
                elif _met == 'nmae1':
                    dmin=0.0001
                    dmax=2
                else:
                    dmin=0
                    dmax=1
                    
                plt.title(f'({string.ascii_letters[spn-1]}) {var_names[_var][0]}',x=0.05, fontsize=8)
                plt.ylim(dmin,dmax)
                if spn == 1:
                    plt.gca().legend(ncol=2, loc=(0.55,0.98), fontsize=6)
                    # plt.gca().legend([bx.artists[0], bx.artists[1]], ['FN', 'FNRS'], ncol=2, loc=(0.55,0.98), fontsize=6)
                else:
                    plt.legend([], [], frameon=False)

                xu.ax_clrXY(axfs=10)
                plt.gca().set_xticklabels(xlabs)
                if _met == 'mef':
                    plt.gca().set_yticks(np.arange(dmin, dmax+0.1, 0.25))
                elif _met == 'nmae1':
                    plt.yscale("log")
                    plt.gca().set_yticks([0.01, 0.1, 1])

                xu.rotate_labels(which_ax='x', rot=90, axfs=9)

                if spn == len(varib_list)-27:
                    plt.xlabel('PFT', fontsize=9)
                else:
                    plt.xlabel('', fontsize=9)
                plt.axhline(y=0, lw=0.443, ls='-',color='k',zorder=1)
                plt.ylabel(_met.upper(), fontsize=9)
                spn=spn+1
                
            plt.savefig(os.path.join(f_dir,f'pft_{exp}_{_freq}_{forname}_{version}.png'), dpi=300,
                    bbox_inches='tight')
            plt.close()
            print('--------------------------------------------------')
