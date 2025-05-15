import os
import numpy as np
import matplotlib.pyplot as plt
import pickle
import string
import extraUtils as xu
from collections import OrderedDict

# Set plot sizes
SMALL_SIZE = 8
MEDIUM_SIZE = 10
BIGGER_SIZE = 12

plt.rc('font', size=SMALL_SIZE)
plt.rc('axes', titlesize=SMALL_SIZE)
plt.rc('axes', labelsize=MEDIUM_SIZE)
plt.rc('xtick', labelsize=SMALL_SIZE)
plt.rc('ytick', labelsize=SMALL_SIZE)
plt.rc('legend', fontsize=SMALL_SIZE)
plt.rc('figure', titlesize=BIGGER_SIZE)

def get_bins(dat, intv):
    bins = np.ones(len(intv) - 1) * np.nan
    allcnt = 0
    datsize = np.sum(~np.isnan(dat))
    for _int in range(len(intv) - 1):
        v1, v2 = intv[_int], intv[_int + 1]
        cnt = np.sum((dat >= v1) & (dat < v2))
        allcnt += cnt
        bins[_int] = cnt / datsize if datsize > 0 else np.nan
    bins[bins == 0] = np.nan
    return bins

def draw_vlines(dat, colo):
    q25 = round(np.nanpercentile(dat, 25), 2)
    q50 = round(np.nanpercentile(dat, 50), 2)
    q75 = round(np.nanpercentile(dat, 75), 2)
    tmp1 = dat[~np.isnan(dat)]
    lt0 = int((tmp1 < 0).sum() * 100 / len(tmp1))
    lt05 = int((tmp1 < 0.5).sum() * 100 / len(tmp1))
    plt.axvline(x=q25, ls=':', lw=0.93, color=colo)
    plt.axvline(x=q50, ls='-', lw=0.93, color=colo)
    plt.axvline(x=q75, ls=':', lw=0.93, color=colo)
    return f'<0.5: {lt05}% [{q25}, {q50}, {q75}]'

# Define forcings and versions
forcings = {
    'cruj': ['CRUJRA.v2_2', '1901', '2019'],
    'crun': ['CRUNCEP.v8', '1901', '2016'],
    'erai': ['ERAinterim.v2', '1979', '2017']
}

fn_versions = "FLUXNET2015".split(" ")
forc_order = ['erai']

varib_list = 'nee gpp reco evapotranspiration transpiration ndvi agb'.split()
var_names = {
    "nee": ["NEE", 'NSE'],
    "gpp": ["GPP", 'NSE'],
    "reco": ["RECO", 'NSE'],
    "evapotranspiration": ["ET", 'NSE'],
    "transpiration": ["T", 'NSE'],
    "ndvi": ["fAPAR", 'NSE'],
    "agb": ["AGB", 'NMAE1R']
}

f_dir = './'
os.makedirs(f_dir, exist_ok=True)

# Define sets for comparison
fnrscolo = '#18A15C'  # Color for the first dataset
fncolo = '#FDB311'     # Color for the second dataset
rscolo = '#C76A7D'

ssets_dict = OrderedDict([('NSE_set3', ('FN', fncolo)), ('NSE_set1', ('FNRS', fnrscolo))]) # for RS comparisons
# ssets_dict = OrderedDict([('NSE_set1', ('O_NSE', '#33CCFF')), ('NNSE_set1', ('O_NNSE', '#FF9933'))]) # for Metric comparisons
ssets_dict = OrderedDict([('NSE_set9', ('RS', rscolo)), ('NSE_set3', ('FN', fncolo)), ('NSE_set1', ('FNRS', fnrscolo))]) # for complete RS comparisons


ssets = list(ssets_dict.keys())
cmpname = "_v_".join(ssets)

# Load data
with open("../../../tmp_metrics_summary/metrics_summary.pkl", "rb") as f:
    data_met = pickle.load(f)

# Prepare data for plotting
datplots = {sset: {} for sset in ssets}
for sset in ssets:
    data_met_sset = data_met[sset.split("_")[0]][sset.split("_")[1]]
    for _var in varib_list:
        _met = var_names[_var][1]
        dat = np.array(data_met_sset[_var][_met])
        if _met == 'NSE':
            dat[dat < -1] = -1
        datplots[sset][_var] = dat

# Define experiments
exp_set = {
    "EC": ['nee gpp reco evapotranspiration transpiration'.split(), 3, 2],
    "RS": ['ndvi agb'.split(), 1, 2]
}

for exp in exp_set.keys():
    exp_info = exp_set[exp]
    varib_list = exp_info[0]
    
    for forcing in forc_order:
        forname = forcings[forcing][0]
        for version in fn_versions:
            site_list = data_met['sites']
            spn = 1
            
            # Set figure size based on experiment type
            fig = plt.figure(figsize=(8, 12.5) if exp == 'EC' else (8, 3.6))
            plt.subplots_adjust(hspace=0.5, wspace=0.2)

            for _var in varib_list:
                _met = var_names[_var][1]
                dat_values = [datplots[sset][_var] for sset in ssets]  # Get data for all datasets
                label_values = [ssets_dict[sset][0] for sset in ssets]  # Get labels for all datasets
                color_values = [ssets_dict[sset][1] for sset in ssets]  # Get colors for all datasets

                # Set limits based on metric type
                if _met == 'NSE':
                    dmin, dmax, plmin, plmax = -1, 1, -1.1, 1.1
                elif _met == 'NMAE1R':
                    plmin, plmax, dmin, dmax = -0.1, 1.1, 0, 1
                else:
                    dmin, dmax, plmin, plmax = 0, 1, -0.1, 1.1

                ax = plt.subplot(exp_info[1], exp_info[2], spn)

                # Draw vertical lines for each dataset
                txt_m_list = [draw_vlines(dat, color_values[i]) for i, dat in enumerate(dat_values)]
                
                # Create title with dataset information
                title_str = f'({string.ascii_letters[spn-1]}) {var_names[_var][0]} ({np.sum(~np.isnan(dat_values[0]))} sites)\n'
                title_str += '\n'.join([f'{label_values[i]}: {txt_m_list[i]}' for i in range(len(ssets))])
                plt.title(title_str, fontsize=9, y=1.01992)
                plt.xlim(plmin, plmax)

                # Get bins for each dataset
                if _met == 'NSE':
                    _intv = 0.1
                    intv = np.arange(-1, 1.1, _intv)
                else:
                    _intv = 0.05
                    maxx = np.nanmax(dat_values[0] + 0.01)
                    intv = np.arange(0, maxx, _intv)

                dat_bins = [get_bins(dat, intv) for dat in dat_values]

                if exp == 'EC':
                    plt.ylim(0, 0.45)

                # Plot bars for each dataset
                bwidth = _intv / 2.33
                xintv = np.array([(intv[i] + intv[i + 1]) / 2 for i in range(len(intv) - 1)])
                
                for i, dat_bin in enumerate(dat_bins):
                    plt.bar(xintv - bwidth if i == 0 else xintv, dat_bin, width=bwidth, linewidth=0, alpha=1,
                            color=color_values[i], label=label_values[i])

                if spn == 1:
                    plt.legend(fancybox=True, loc='upper left')
                xu.ax_clrXY(axfs=11)
                plt.xlabel(_met.upper(), fontsize=9)
                spn += 1

            plt.savefig(os.path.join(f_dir, f'rf_hists_{exp}_{forname}_{version}_{cmpname}_jl.png'), dpi=300,
                        bbox_inches='tight')
            plt.close()
            print('--------------------------------------------------')
