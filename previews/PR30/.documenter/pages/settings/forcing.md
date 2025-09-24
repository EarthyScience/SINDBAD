
# Forcing Configuration {#Forcing-Configuration}

The `forcing.json` file configures the input dataset for SINDBAD experiments, defining how forcing data is processed and integrated into model runs.

## Data Dimensions {#Data-Dimensions}

The `data_dimension` section specifies the structure of input forcing datasets, enabling proper data processing for spatial and temporal operations.

:::tabs

== Explanation

```json
"data_dimension": {
    "time": "Name of the time dimension in the dataset",
    "permute": "Order of dimensions in the processed data",
    "space": "List of spatial dimensions"
}
```


== Example

```json
"data_dimension": {
    "time": "time",
    "permute": ["time", "longitude", "latitude"],
    "space": ["longitude", "latitude"]
}
```


:::

## Default Forcing Settings {#Default-Forcing-Settings}

The `default_forcing` section defines default attributes for all forcing variables. These settings apply unless overridden in individual variable configurations.

:::tabs

== Explanation

```json
"default_forcing": {
    "additive_unit_conversion": "Flag for additive (true) or multiplicative (false) unit conversion",
    "bounds": "Valid data range after unit conversion",
    "data_path": "Path to the data file (absolute or relative to experiment base)",
    "depth_dimension": "Name of depth dimension (null if none)",
    "is_categorical": "Flag for categorical variables",
    "standard_name": "Descriptive variable name",
    "sindbad_unit": "Unit used within SINDBAD",
    "source_product": "Data source identifier",
    "source_to_sindbad_unit": "Unit conversion factor",
    "source_unit": "Original data unit",
    "source_variable": "Variable name in source file",
    "space_time_type": "Data type classification"
}
```


== Example

```json
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
}
```


:::

## Spatial Subsetting {#Spatial-Subsetting}

The `forcing_mask` section configures spatial subsetting of forcing data, enabling experiments on specific regions without creating new datasets.

:::tabs

== Explanation

```json
"forcing_mask": {
    "data_path": "Path to the mask file",
    "source_variable": "Mask variable name in the file"
}
```


== Example

```json
"forcing_mask": {
    "data_path": null,
    "source_variable": null
}
```


:::

::: info Note Temporal subsetting is configured in the `time` section of `experiment.json`. :::

## Variable Configuration {#Variable-Configuration}

The `variables` section lists all forcing variables required for the experiment. Only settings that differ from `default_forcing` need to be specified.

:::tabs

== Explanation

```json
"variables": {
    "f_variable_name": {
        "bounds": "Valid range for the variable",
        "standard_name": "Descriptive name",
        "sindbad_unit": "SINDBAD unit",
        "source_unit": "Original unit",
        "source_variable": "Variable name in source file"
    }
}
```


== Example

```json
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
    }
}
```


:::

::: tip Variable Naming Convention
- Use `f_` prefix for forcing variables loaded from data files
  
- This convention distinguishes them from variables computed within SINDBAD
  

:::

::: warning Data Validation
- Values outside specified bounds are truncated, not replaced with NaN
  
- Ensure all required variables are available in the forcing dataset
  
- Verify unit conversions and data types match model requirements
  

:::
