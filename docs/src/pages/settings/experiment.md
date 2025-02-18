## experiment
The experiment.json is the main settings file for SINDBAD experiment. It is divided into the following main sections

### basics
The basics section defines the settings for an experiment as well as the basic information for experiment

````json
"basics": {
    "config_files": SINDBAD configuration files{
      "forcing": name of the configuration file for forcing data,
      "model_structure": name of the configuration file for model structure,
      "optimization": name of the configuration file for parameter optimization
    },
    "domain": the domain of the experiment for e.g., global,
    "name": name of the experiment,
    "time": {
      "date_begin": a date string for the beginning of the experiment, e.g., "1979-01-01",
      "date_end": a date string for the end of the experiment, e.g., "2017-12-31",
      "temporal_resolution": the temporal resolution of model simulation/experiment, e.g., hour, day, week, month, etc.
    }
  },
````
### exe_rules
This section defines the settings for execution of the model and experiment

````json
"exe_rules": {
    "input_array_type": data type to be used for input array after reading from forcing data, e.g., "keyed_array",
    "input_data_backend": data backed of forcing dataset, e.g., "netcdf",
    "land_output_type": output array backed to store to model output time series, e.g., "array",
    "longtuple_size": length of the longtuple to store the tuple of models,
    "model_array_type": data backend of array/vector within the SINDBAD models, e.g., "static_array",
    "model_number_type": type of number to be used inside SINDBAD models, e.g., "Float32",
    "parallelization": backend used for parallelization in space, e.g., "threads",
    "tolerance": a numerical tolerance used for checking threshold of numerical errors, for instance, for water balance, e.g., 1.0e-2,
    "yax_max_cache": a numeric value for cache size during YaxArray based model runs
  },
````
### flags
This section sets the flags to run the experiment for different targets such as forward run, optimization/calibration etc. Note that all fields in flags take only ```true``` or ```false``` as values.

````json
"flags": {
    "calc_cost": set/unset calculation of parameter/simulation cost compared to the observations listed in optimization.json settings, e.g., true,
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

### model_output
Settings related to output type and variables

````json
"model_output": {
    "depth_dimensions": list of variables with sizes in depth direction{
      "d_cEco": 8,
      "d_snow": "snowW",
    },
    "format": output format of the data, e.g., "zarr" for zarr output, "nc" for netcdf,
    "output_array_type": data backend for output variable, e.g., "array",
    "path": non-standard path to save model output, `null` is used for default directory,
    "plot_model_output": flag to plot the model output,
    "save_single_file": flag to save one file with all variables when `true` else saves one file per variable,
    "variables": list of variables to save into output files. Uses a convention of `field.name:depth/layers`. The values denote the number of layers in depth dimension needed for the variable. It either takes `null` for 1 layer, a string defined in `depth_dimensions` above or number indicating the number of layers, e.g., 4 {
      "diagnostics.auto_respiration_f_airT": null,
      "diagnostics.c_eco_k_f_soilW": "d_cEco",
      "diagnostics.root_water_efficiency": 4,
    }
  },
````

### model_spinup
Setup of model spinup

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