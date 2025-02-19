## forcing

includes the setup of the forcing dataset for an experiment. 

### Dimensions of data
In this section, the names and orders of the dimensions in the input forcing datasets are given. Based on these, the forcing data are processed in a way SINDBAD needs to run the loops in space and time. 

:::tabs

== Explanation
````json
"data_dimension":  {
    "time": name of the time dimension in data,
    "permute": a list shows the order of dimension in the data,
    "space": a list of spatial dimensions
  },
````
== Example
````json
"data_dimension": {
    "time": "time",
    "permute": ["time", "longitude", "latitude"],
    "space": ["longitude", "latitude"]
}
````
:::

### Default forcing variable
In this section, the default values of the attributes of each forcing variable are set. Each variable takes these attributes unless they are overwritten in the settings of individual variables under ```variables``` section below. The fields for each forcing variable can be a subset of the default forcing. The values for each forcing are generated as a union of default forcing and each variable.

:::tabs

== Explanation
````json
"default_forcing":  {
    "additive_unit_conversion": a flag to indicated if the unit conversion is additive. If true, the unit conversion factor is added to the data, if false, it is multiplied.
    "bounds": a list of two numbers indicating the viable bounds of data after unit conversion, e.g., [0, 100] for a variable. Note that the data outside bounds are truncated and not replaced by a NaN,
    "data_path": path to the data file, e.g., "../data/BE-Vie.1979.2017.daily.nc". Note that the path can be absolute or relative to the base Julia environment of a given experiment,
    "depth_dimension": name of the depth dimension in case of variables with depth dimension, defaults to null which means none,
    "is_categorical": flag to indicate if the data is categorical variable,
    "standard_name": a metadata used to identify variable and improve clarity. Note that it is not used in data processing and calculation.,
    "sindbad_unit": a metadata used to identify variable units within SINDBAD and improve clarity. Note that it is not used in data processing and calculation.,
    "source_product": a metadata used to identify data source and improve clarity. Note that it is not used in data processing and calculation, e.g., "FLUXNET",
    "source_to_sindbad_unit": a numerical value used for unit conversion of the variable on the go,
    "source_unit": a metadata used to identify variable units in the source data and improve clarity. Note that it is not used in data processing and calculation.,
    "source_variable": a string variable name in the data file. Note that SINDBAD variable names are the keys listed under variables,
    "space_time_type": a string indicating the data type , e.g., "spatiotemporal" for data with time and space dimensions
  },
````
== Example
````json
"default_forcing": {
    "additive_unit_conversion": false,
    "bounds": [],
    "data_path": "../data/BE-Vie.1979.2017.daily.nc",
    "depth_dimension": null,
    "is_categorical": false,
    "standard_name": null,
    "sindbad_unit": null,
    "source_product": "FLUXNET",
    "source_to_sindbad_unit": 1,
    "source_unit": null,
    "source_variable": null,
    "space_time_type": "spatiotemporal"
  },
````
:::

### Forcing subset
This section sets information related to the mask used for spatial subsetting of the forcing from the data in the file. This setting is envisioned to run the experiment for a small subset without having to create new data every time. Note that the temporal sub-setting is through ```time``` section of the ```experiment``` settings. 

:::tabs

== Explanation
````json
"forcing_mask":  {
    "data_path": path to the mask file,
    "source_variable": variable name of the mask within the file
  },
````
== Example
````json
"forcing_mask": {
    "data_path": null,
    "source_variable": null
  }
````
:::

### Variables
In this section, a list of all forcing variables needed for a given experimental run is provided. The list is free-form and can be reduced/extended based on model structure. The variables listed here should be available in the forcing dataset. Note that only the information that differs from the ```default_forcing``` has to be set here.

:::tabs

== Explanation
````json
"variables":  
  {
    "f_ambient_CO2": The key is the variable name used internally in SINDBAD. By convention used f_ as the prefix of all forcing variables that are loaded from data file. This allows separation with variables that computed within SINDBAD 
    {
      "bounds": same meaning as default forcing but set the bounds for the given variable, e.g. for ambient CO2: [200, 500],
      "standard_name": "ambient_CO2",
      "sindbad_unit": "ppm",
      "source_unit": "ppm",
      "source_variable": "atmCO2_SCRIPPS_global"
    }
  }
````
== Example
````json
"variables": {
    "f_ambient_CO2": {
        "bounds": [200, 500],
        "standard_name": "ambient_CO2",
        "sindbad_unit": "ppm",
        "source_unit": "ppm",
        "source_variable": "atmCO2_SCRIPPS_global"
    },
    "f_clay": {
        "bounds": [0.0, 100.0],
        "standard_name": "CLAY",
        "sindbad_unit": "-",
        "source_product": "soilgrids",
        "source_to_sindbad_unit": 0.01,
        "source_unit": "%",
        "source_variable": "CLYPPT_SoilGrids",
        "space_time_type": "spatiovertical"
    },
    "f_dist_intensity": {
        "bounds": [-0.001, 1.1],
        "is_categorical": true,
        "standard_name": "isDisturbed flag for disturbance",
        "sindbad_unit": null,
        "source_product": "Besnard2018",
        "source_unit": null,
        "source_variable": "dist_frac_sb2018"
    },
    "f_orgm": {
        "bounds": [0.0, 100.0],
        "standard_name": "CLAY",
        "sindbad_unit": "-",
        "source_product": "soilgrids",
        "source_to_sindbad_unit": 0.0,
        "source_unit": "%",
        "source_variable": "OCSTHA_SoilGrids",
        "space_time_type": "spatiovertical"
    }
  }
````
:::
