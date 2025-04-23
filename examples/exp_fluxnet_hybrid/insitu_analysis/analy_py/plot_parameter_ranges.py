import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import pickle
from collections import OrderedDict
import copy

import extraUtils as xu

import json
import sys
import io

# Set the standard output to UTF-8
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

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

def fix_box_colors(boxes, colors):
    for item in ['boxes', 'whiskers', 'fliers', 'medians', 'caps']:
        for b, _box in enumerate(boxes):
            patch_color = colors[b]
            plt.setp(_box[item], color='k', linewidth=0.53)
            for p, patch in enumerate(_box['boxes']):
                patch.set(color=patch_color)
    return

def add_x_labels(params, xlocs):
    pnames_eq = json.load(open('./pnames_from_eqn_jl.json', encoding='utf-8'))

    pnames=[]
    for p in params:
        p_key = p.replace("___",".")
        pnames.append(p.split("___")[0]+'\n'+pnames_eq[p_key])
    plt.gca().set_xticks(xlocs)
    plt.gca().set_xticklabels(pnames, fontsize=8)

def save_params_list_json(params):
    import json
    p_dict={}
    for p in params:
        p_dict[p]=""
    with open("pnames_wr.json", "w") as write_file:
        json.dump(p_dict, write_file, indent=4)
    return

forcing='erai'
version='FLUXNET2015'

site_info = pd.read_csv(
    "/Net/Groups/BGI/scratch/skoirala/prod_sindbad.jl/examples/exp_WROASTED/settings_WROASTED/site_names_disturbance.csv")

site_list= site_info['site'].values

print(site_list)

fnrscolo='#18A15C'
fncolo='#FDB311'
rscolo = '#C76A7D'

ssets_dict = OrderedDict([('NSE_set3', ('FN', fncolo)), ('NSE_set1', ('FNRS', fnrscolo))]) # for RS comparisons
ssets_dict = OrderedDict([('NSE_set9', ('RS', rscolo)), ('NSE_set3', ('FN', fncolo)), ('NSE_set1', ('FNRS', fnrscolo))]) # for complete RS comparisons
ssets_dict = OrderedDict([('NSE_set1', ('O_NSE', '#33CCFF')), ('NNSE_set1', ('O_NNSE', '#FF9933'))]) # for Metric comparisons

ssets = list(ssets_dict.keys())

cmpname = "_v_".join(ssets)
run_name = 'Insitu_v202503'


read_params=True
read_params=False
label_defaults=False

print(ssets)

if not read_params:
    site_params={}
    for sset in ssets:
        site_params[sset]={}
    for sset in ssets:
        set_name = sset.split("_")[1]
        opt_name = sset.split("_")[0]

        for site in site_list:
            optFile = f'/Net/Groups/BGI/tscratch/skoirala/{run_name}/{forcing}/{set_name}/{site}_{run_name}_{forcing}_{set_name}_{opt_name}/optimization/{run_name}_{forcing}_{set_name}_{opt_name}_{site}_model_parameters_to_optimize.csv'
            if os.path.exists(optFile):
                optp = pd.read_csv(optFile, encoding='utf-8')
                # print(optp.columns.tolist())
            param_list = optp['name_full'].values
            # print(param_list)
            defaults_unscaled=copy.deepcopy(np.array(list(optp['default'].values)))
            defaults=optp['default'].values
            optims = optp['optim'].values
            lowers = optp['lower'].values
            uppers = optp['upper'].values
            for p, p_name in enumerate(param_list):
                mod=p_name.split('.')[0]
                param=p_name.split('.')[1]
                p_key = f'{mod}___{param}'
                if p_key not in site_params[sset]:
                    print(f"Adding {param} to {sset} for site: {site}")
                    site_params[sset][p_key]=[]
                opt_scaled = (optims[p] - lowers[p])/(uppers[p] - lowers[p])
                def_scaled = (defaults[p] - lowers[p])/(uppers[p] - lowers[p])

                site_params[sset][p_key] = np.append(site_params[sset][p_key], opt_scaled)
                defaults[p] = def_scaled
                print(p_key, optims[p], defaults[p], lowers[p], uppers[p])
                print("----------------------------")
    site_params["defaults"]=defaults
    site_params["defaults_unscaled"]=defaults_unscaled
    with open(f'site_params_{forcing}_{version}_{cmpname}_{run_name}.pkl', "wb") as tf:
        pickle.dump(site_params,tf)  
else:
    with open(f'site_params_{forcing}_{version}_{cmpname}_{run_name}.pkl', "rb") as tf:
        site_params = pickle.load(tf)  

# Prepare data
set_names=[]
opt_names=[]
modfiles=[]
set_labels=[]
set_colors=[]
data_plot = []
for sset in ssets:
    set_name = sset.split("_")[1]
    opt_name = sset.split("_")[0]
    set_label = ssets_dict[sset][0]
    set_color = ssets_dict[sset][1]
    data_plot.append(np.array(list(site_params[sset].values())))
    param_list = list(site_params[sset].keys())
    set_names.append(set_name)
    opt_names.append(opt_name)
    set_labels.append(set_label)
    set_colors.append(set_color)

defaults = site_params['defaults']
defaults_unscaled = site_params['defaults_unscaled']
num_params = len(defaults)  # Number of parameters

# Set up figure
plt.figure(figsize=(12, 10))
plt.subplots_adjust(hspace=0.475, wspace=0.3)
blank_fraction=0.2
xintv_base = np.arange(1, num_params + 1)  # Adjust to the number of parameters
bwidth = (1 - blank_fraction) / len(ssets)


# xintv = xintv - len(ssets)/2
xintv = xintv_base - bwidth * (len(ssets) -1 ) / 2.0

# Determine the number of subplots needed
num_subplots = 2
params_per_subplot = num_params // num_subplots + (num_params % num_subplots > 0)

for ns in range(num_subplots):
    plt.subplot(num_subplots, 1, ns + 1)
    xu.ax_clrXY(axfs=11)
    xu.rotate_labels(which_ax='x', rot=90, axfs=11)

    start_idx = ns * params_per_subplot
    end_idx = min(start_idx + params_per_subplot, num_params)

    dat_subplot = [data[start_idx:end_idx, :] for data in data_plot]

    param_list_subplot = param_list[start_idx:end_idx]
    xintv_subplot = xintv[start_idx:end_idx]
    xintv_base_subplot = xintv_base[start_idx:end_idx]
    defaults_subplot = defaults[start_idx:end_idx]
    defaults_unscaled_subplot = defaults_unscaled[start_idx:end_idx]

    # Create boxplots for the current set of parameters
    boxes = []
    for j, data in enumerate(dat_subplot):

        # print(j, data, data.shape)
        box_positions = xintv_subplot + bwidth*j
        box_ = plt.boxplot(data.T, 
                       positions=box_positions, 
                       widths=bwidth, 
                       manage_ticks=True,
                       patch_artist=True, 
                       showfliers=False)
        boxes.append(box_)

    plt.scatter(xintv_base_subplot, defaults_subplot, 
                marker="*", color='red', s=20, zorder=10)
    if label_defaults:
        # Add labels for each point
        for i in range(len(xintv_base_subplot)):
            plt.text(xintv_base_subplot[i], defaults_subplot[i], round(defaults_unscaled_subplot[i],2), fontsize=9, ha='center', va='bottom', rotation=90)


    fix_box_colors(boxes, set_colors)
    add_x_labels(param_list_subplot, xintv_base_subplot)
    if ns == 0:
        plt.ylabel('Scaled across-site\nparameter variability (-)', fontsize=11, y=-0.12)
        plt.gca().legend([_box["boxes"][0] for _box in boxes], set_labels, ncol=2, loc=(0.8, 1.03))
    else:
        plt.xlabel('Model parameters', fontsize=11)

    plt.ylim(-0.05, 1.05)

# Save the figure
plt.savefig(f'parameter_variability_{forcing}_{version}_{cmpname}_{run_name}.png', dpi=300, bbox_inches='tight')