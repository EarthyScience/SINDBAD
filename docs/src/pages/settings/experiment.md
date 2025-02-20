## SINDBAD Configuration

## experiment

The experiment.json is the main settings file for SINDBAD experiment. 

It is divided into the following main sections

### basics
The basics section defines the settings for an experiment as well as the basic information for experiment

:::tabs

== Explanation
````json
"basics": {
    "config_files": SINDBAD configuration files{
      "forcing": name of the configuration file for forcing data,
      "model_structure": name of the configuration file for model structure,
      "optimization": name of the configuration file for parameter optimization
    },
    "domain": the domain of the experiment,
    "name": name of the experiment,
    "time": {
      "date_begin": a date string for the beginning of the experiment,
      "date_end": a date string for the end of the experiment,
      "temporal_resolution": the temporal resolution of model simulation/experiment. Supported values are one of ["second", "minute", "halfhour", "hour", "day", "week", "month", "year", "decade"]
    }
  },
````
== Example
````json
  "basics": {
    "config_files": {
      "forcing": "forcing.json",
      "model_structure": "model_structure.json",
      "optimization": "optimization.json"
    },
    "domain": "FLUXNET",
    "name": "WROASTED",
    "time": {
      "date_begin": "1979-01-01",
      "date_end": "2017-12-31",
      "temporal_resolution": "day"
    }
  },
````
:::

### exe_rules
This section defines the settings for execution of the model and experiment

:::tabs

== Explanation
````json
"exe_rules": {
    "input_array_type": data type to be used for input array after reading from forcing data,
    "input_data_backend": data backed of forcing dataset,
    "land_output_type": output array backed to store to model output time series,
    "longtuple_size": length of the longtuple to store the tuple of models,
    "model_array_type": data backend of array/vector within the SINDBAD models,,
    "model_number_type": type of number to be used inside SINDBAD models,
    "parallelization": backend used for parallelization in space,
    "tolerance": a numerical tolerance used for checking threshold of numerical errors, for instance, for water balance,
    "yax_max_cache": a numeric value for cache size during YaxArray based model runs
  },
````
== Example
````json
  "exe_rules": {
    "input_array_type": "keyed_array",
    "input_data_backend": "netcdf",
    "land_output_type": "array",
    "longtuple_size": null,
    "model_array_type": "static_array",
    "model_number_type": "Float32",
    "parallelization": "threads",
    "tolerance": 1.0e-2,
    "yax_max_cache": 2e9
  },
````
:::

::: tip

- use ```subptypes(SindbadInputDataType)``` to list available options for ```input_array_type```.
- use ```subtypes(SindbadInputBackend)``` to list all supported data backends for ```input_data_backend```.
:::

### flags
This section sets the flags to run the experiment for different targets such as forward run, optimization/calibration etc. Note that all fields in flags take only ```true``` or ```false``` as values.

:::tabs

== Explanation
````json
"flags": {
    "calc_cost": set/unset calculation of parameter/simulation cost compared to the observations listed in optimization.json settings,
    "catch_model_errors": stop the model run when there are errors internally, e.g., due to water balance,
    "debug_model": run model for a single time step and display the diagnostics needed for debugging models,
    "filter_nan_pixels": remove NaN pixels from input array,
    "inline_update": run the update function in each model immediately after compute. This means that the model state is updated within a single time step and before the call to the next model,
    "run_forward": do the forward run of models,
    "run_optimization": do the parameter calibration,
    "save_info": save the experiment info as jld2 file,
    "spinup_TEM": do the spinup,
    "store_spinup": store the end state of each spinup sequence as a tuple of land,
    "use_forward_diff": trigger the use of Dual data type for use with ForwardDiff.jl, e.g., in case of ML-Hybrid model experiments
  },
````
== Example
````json
 "flags": {
    "calc_cost": true,
    "catch_model_errors": false,
    "debug_model": false,
    "filter_nan_pixels": false,
    "inline_update": false,
    "run_forward": true,
    "run_optimization": true,
    "save_info": true,
    "spinup_TEM": true,
    "store_spinup": false,
    "use_forward_diff": false
  },
````
:::

### model_output
Settings related to output type and variables

:::tabs

== Explanation
````json
"model_output": {
    "depth_dimensions": list of variables with sizes in depth direction{
      "d_cEco": 8,
      "d_snow": "snowW",
    },
    "format": output format of the data, e.g., "zarr" for zarr output, "nc" for netcdf,
    "output_array_type": data backend for output variable,
    "path": non-standard path to save model output, `null` is used for default directory,
    "plot_model_output": flag to plot the model output,
    "save_single_file": flag to save one file with all variables when `true` else saves one file per variable,
    "variables": list of variables to save into output files. Uses a convention of `field.name:depth/layers`. The values denote the number of layers in depth dimension needed for the variable. It either takes `null` for 1 layer, a string defined in `depth_dimensions` above or number indicating the number of layers, e.g., 4 
      {
        "diagnostics.auto_respiration_f_airT": null,
        "diagnostics.c_eco_k_f_soilW": "d_cEco",
        "diagnostics.root_water_efficiency": 4,
      }
  },
````
== Example
````json
"model_output": {
  "depth_dimensions": {
    "d_cEco": 8,
    "d_snow": "snowW",
    "d_soil": "soilW",
    "d_tws": "TWS"
  },
  "format": "zarr",
  "output_array_type": "array",
  "path": null,
  "plot_model_output": false,
  "save_single_file": true,
  "variables": {
    "diagnostics.auto_respiration_f_airT": null,
    "diagnostics.k_shedding_leaf_frac": null,
    "diagnostics.k_shedding_root_frac": null,
    "diagnostics.leaf_to_reserve_frac": null,
    "diagnostics.reserve_to_leaf_frac": null,
    "diagnostics.reserve_to_root_frac": null,
    "diagnostics.root_to_reserve_frac": null,
    "diagnostics.c_eco_k_f_soilT": null,
    "diagnostics.c_eco_k_f_soilW": "d_cEco",
    "fluxes.auto_respiration": null,
    "fluxes.base_runoff": null,
    "fluxes.evapotranspiration": null,
    "fluxes.gpp": null,
    "fluxes.gw_recharge": null,
    "fluxes.hetero_respiration": null,
    "fluxes.nee": null,
    "fluxes.runoff": null,
    "fluxes.snow_melt": null,
    "fluxes.surface_runoff": null,
    "fluxes.transpiration": null,
    "diagnostics.gpp_climate_stressors": 4,
    "diagnostics.gpp_f_soilW": null,
    "pools.cEco": "d_cEco",
    "pools.groundW": 1,
    "pools.snowW": 1,
    "pools.soilW": "d_soil",
    "pools.TWS": "d_tws",
    "diagnostics.c_allocation": "d_cEco",
    "fluxes.c_eco_efflux": "d_cEco",
    "fluxes.c_eco_flow": "d_cEco",
    "fluxes.c_eco_influx": "d_cEco",
    "diagnostics.c_eco_k": "d_cEco",
    "fluxes.c_eco_out": "d_cEco",
    "diagnostics.c_flow_A_vec": 10,
    "states.fAPAR": null,
    "states.frac_snow": null,
    "states.PAW": "d_soil",
    "diagnostics.root_water_efficiency": "d_soil",
    "diagnostics.transpiration_supply": null,
    "diagnostics.water_balance": null,
    "diagnostics.WUE": null
  }
}
````
:::

::: info

Note that the list of variables follow the convention of ```${field}.${subfield} ``` of ```land```.

:::

### model_spinup
Setup of model spinup

:::tabs

== Explanation
````json
"model_spinup": {
    "restart_file": path to the restart file. If null is used, no restart file is used,
    "sequence": a sequence of list of information on how to run parts of model spinup. Each element/block is run serially and repeated based on the settings
      [{
        "forcing": which forcing to use for the sequence block, e.g., "first_year" for using the first year of forcing data,
        "n_repeat": number of repetition of the block, e.g., 200,
        "spinup_mode": list of models or spinup method to use in the block, e.g., "all_forward_models" to run all forward models during the execution of the block
      }]
````
== Example
````json
"model_spinup": {
    "restart_file": null,
    "sequence": [
      {
        "forcing": "first_year",
        "n_repeat": 200,
        "spinup_mode": "all_forward_models"
      }
    ]
  }
````
:::
