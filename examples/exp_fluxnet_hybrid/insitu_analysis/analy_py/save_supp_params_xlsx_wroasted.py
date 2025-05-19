import json
import pandas as pd
import os
import numpy as np

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
temp_reso ='daily'

forcing='erai'
version='FLUXNET2015'
forname= forcings[forcing][0]
syear = int(forcings[forcing][1])
eyear = int(forcings[forcing][2])
site_list_path = f"../../fluxnet_sites_info/site_list_{version}.csv"
site_list = [site.strip() for site in open(site_list_path).readlines()]
fn_dir = get_cliff_dirname(version,temp_reso)
param_list=[]
site = 'AT-Neu'
optFile = os.path.join(f'/Net/Groups/BGI/scratch/skoirala/v202312_ml_wroasted/sindbad_raw_set1/{fn_dir}/{forname}/{site}/optimization/optimized_Params_FLUXNET_pcmaes_{version}_daily_{site}.json')
print(site, optFile, os.path.exists(optFile))
optp=json.load(open(optFile))['parameter']
for _opt in optp.keys():
    print(_opt, optp[_opt])
    for _mod in optp[_opt].keys():
        param_list=np.append(param_list, f'{_opt}.{_mod}')

param_list = np.sort(list(set(param_list)))

header = 'SN;Module;Approach;Parameter;Default;Range;Units;Description'

ms = json.load(open(f'/Net/Groups/BGI/work_3/sindbad/project/progno/sindbad-wroasted/sandbox/sb_wroasted/settings_wroasted_sets/modelStructure.json'))['modules']

site_params={}
ofile = open(f'tmp_ptab.csv', "w")
ofile.write(header+'\n')
defaults=[]
sn = 1
for p_name in param_list:
    mod=p_name.split('.')[0]
    param=p_name.split('.')[1]
    appr = json.load(open(f'/Net/Groups/BGI/scratch/skoirala/overview_sindbad/merged_sindbad/sindbad/model/modules/{mod}/{ms[mod]["apprName"]}/{ms[mod]["apprName"]}.json'))['params']
    # print (appr)
    defval = appr[param]['Default']
    lval = appr[param]['LowerBound']
    uval = appr[param]['UpperBound']
    description =  appr[param]['Name']
    unit =  appr[param]['Unit']
    if len(description.strip()) == 0:
        description = '-'
    if unit.strip() == "":
        unit = '-'
    unit = unit.replace('[', '')
    unit = unit.replace(']', '')
    w_str = f'{sn};{mod};{ms[mod]["apprName"].split("_")[1]};{param};{defval};[{lval}, {uval}];{unit};{description}\n'
    ofile.write(w_str)
    sn += 1
    print(p_name, defval, lval, uval, unit, description)
    print("----------------------------")
ofile.close()
csv = pd.read_csv(f'tmp_ptab.csv', sep=';')
print(csv)
with pd.ExcelWriter(f'supp_table_params_wroasted.xlsx') as writer:
    csv.to_excel(writer, index=False)
os.system(f'rm -f tmp_ptab.csv')
