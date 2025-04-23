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
# import pycountry
import pickle
import json
import matplotlib as mpl

import extraUtils as xu
# import perf_metrics as pm

from matplotlib.gridspec import GridSpec

import matplotlib.pyplot as plt
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

def fix_cb(_cb,ax_fs=6):
    _cb.ax.tick_params(labelsize=ax_fs,size=2,width=0.3)
    print (_cb.ax.xaxis.get_ticklocs())
#    cb.ax.set_xscale(col_scale)
    ##hack the lines of the colorbar to make them white, the same color of background so that the colorbar looks broken.
    _cb.outline.set_alpha(0.)
    _cb.outline.set_color('white')
    _cb.outline.set_linewidth(1)
    # _cb.dividers.set_linewidth(0)
    # _cb.dividers.set_alpha(1.0)
    # _cb.dividers.set_color('white')
    for ll in _cb.ax.xaxis.get_ticklines():
        ll.set_alpha(0.)
def mk_colos(axco1, cbflag, orient='horizontal'):
#    axco1 = divider.append_axes("bottom", size=0.1,pad=0.071,aspect=0.025)

    cb=mpl.colorbar.ColorbarBase(axco1,cmap=cm2, norm=BoundaryNorm(bounds),boundaries=bounds[1:-1], orientation = orient, spacing='proportional',ticks=bounds[2:-2],extend='both', drawedges=True)
    xlabs=[]
    for _b in bounds[2:-2]:
        if abs(_b) < 1 and abs(_b) !=0.:
            xlabs=np.append(xlabs,'%.2f'%(_b))
        elif (_b) < 0:
            xlabs=np.append(xlabs,'%.2f'%(_b))
        elif cbflag == 2:
            xlabs=np.append(xlabs,'%.2f'%(_b))
        elif abs(_b) == 0:
            xlabs=np.append(xlabs,'%d'%(_b))
        else:
            xlabs=np.append(xlabs,'%d'%(_b))
    if '0.00' in xlabs.tolist():
        ind0=xlabs.tolist().index('0.00')
        xlabs[ind0]='0'
    cbfs=7
    if orient == 'horizontal':
        cb.ax.set_xticklabels(xlabs,fontsize=cbfs,rotation=90)
        for ll in cb.ax.xaxis.get_ticklines():
            ll.set_alpha(0.)
    else:
        cb.ax.set_yticklabels(xlabs,fontsize=cbfs)
        for ll in cb.ax.yaxis.get_ticklines():
            ll.set_alpha(0.)

    cblw=1.2
    # cb.outline.set_alpha(1.)
    cb.outline.set_edgecolor('white')
    cb.outline.set_linewidth(cblw)
    # cb.outline.set_color('white')
    cb.dividers.set_linewidth(cblw)
    # cb.dividers.set_alpha(0.)
    cb.dividers.set_color('white')
    return cb


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
varib_list = 'NEE gpp cRECO evapTotal tranAct fAPAR'.split()

moddirM = '/Net/Groups/BGI/scratch/skoirala/cliffNet_wroasted_out'
obsdirM = '/Net/Groups/BGI/scratch/skoirala/cliffNet'
outDirM = '/Net/Groups/BGI/scratch/skoirala/cliffNet_wroasted_out'

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
site_miss={'FLUXNET2015': 'AR-Vir, AU-Ade, AU-Fog, AU-Whr, BR-Sa1, CA-TP2, CH-Lae, DE-Akm, DE-Spw, DE-Zrk, DK-Eng, ES-Ln2, FI-Jok, IT-Cp2, JP-MBF, RU-Sam, RU-SkP, RU-Tks, RU-Vrk, SJ-Blv, SN-Dhr, US-GBT, US-ORv, US-Sta, US-Tw1, US-Tw2, US-Tw3, US-UMd, CA-Man, DE-RuR, DE-RuS'.split(', '),
'LaThuile': 'CA-TP2, CH-Oe2, CZ-wet, ES-LJu, JP-Tak, SE-Sk2, US-FR2'.split(', ')}
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
sset='set1'
for forcing in forc_order:
    forname= forcings[forcing][0]
    for version in fn_versions:

        with open(f"./perf_summary_wroasted_sets/performance_summary_{forname}_{version}.pkl", "rb") as tf:
            data_met = pickle.load(tf)
        site_list = data_met[sset]['sites']
        print(data_met[sset].keys())
        print(data_met[sset]['sites'])
        # datplot=np.ones((len(varib_list), len(site_list)))
        # print (datplot)
        spn=1
        fig = plt.figure(figsize=(7,11))
        # plt.suptitle(, x=0.2, y=1.032, color='#888888')
        cmap = 'seismic'
        # datplot[_varI, :] = dat
        ax_l=[x0+(spn-5)*wp,y0-ym*int((spn-1)/2)*hp,wp,hp]
            
        ax = plt.axes(ax_l, projection=crs.Robinson())
        # ax=plt.subplot(3,2,spn,projection=crs.Robinson())
        ax.set_global()

        ax.add_feature(cfeature.COASTLINE, edgecolor="#999999",lw=0.3)
        # ax.add_feature(cfeature.BORDERS, edgecolor="tomato")
        # ax.outline_patch.set_linewidth(0.2)
        # ax.outline_patch.set_edgecolor('#888888')
        ax.outline_patch.set_edgecolor('none')
        # ax.gridlines(linestyle=':',zorder=0,lw=0.1)#,draw_labels=True,xlabels_top = False,ylabels_right = False)
    # ax.gridlines()
        print(len(data_met[sset]['lon']), len(data_met[sset]['lat']))
        plt.scatter(x=data_met[sset]['lon'], y=data_met[sset]['lat'],
                    c='red',
                    marker='.',
                    s=0.2,
                    # alpha=0.5,
                    zorder=5,
                    transform=crs.PlateCarree()) ## Important
        # plt.hist(dat,bins=50)
        # xu.rem_axLine()
        # plt.title(f'Site Locations in FLUXNET2015 Dataset [{sum(~np.isnan(dat))} sites]',fontsize=6,y=0.94)
    plt.savefig(os.path.join(f_dir,f'locations_{forname}_{version}.pdf'), dpi=350,
        bbox_inches='tight')
    plt.savefig(os.path.join(f_dir,f'locations_{forname}_{version}.png'), dpi=350,
        bbox_inches='tight')
    plt.close()
    print('--------------------------------------------------')


# fig = plt.figure(figsize=(10,8))

# ax = fig.add_subplot(1,1,1, projection=crs.Robinson())

# ax.set_global()

# ax.add_feature(cfeature.COASTLINE, edgecolor="#cccccc")
# # ax.add_feature(cfeature.BORDERS, edgecolor="tomato")
# ax.gridlines()

# plt.scatter(x=data_met['lon'], y=data_met['lat'],
#             color="dodgerblue",
#             s=1,
#             alpha=0.5,
#             transform=crs.PlateCarree()) ## Important

# plt.show()