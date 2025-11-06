<details class='jldocstring custom-block' open>
<summary><a id='SindbadData' href='#SindbadData'><span class="jlbinding">SindbadData</span></a> <Badge type="info" class="jlObjectType jlModule" text="Module" /></summary>



```julia
SindbadData
```


The `SindbadData` package provides tools for handling and processing SINDBAD-related input data and processing. It supports reading, cleaning, masking, and managing data for SINDBAD experiments, with a focus on spatial and temporal dimensions.

**Purpose:**

This package is designed to streamline the ingestion and preprocessing of input data for SINDBAD experiments. 

**Dependencies:**
- `Sindbad`: Provides the core SINDBAD models and types.
  
- `SindbadUtils`: Provides utility functions for handling NamedTuple, spatial operations, and other helper tasks for spatial and temporal operations.
  
- `AxisKeys`: Enables labeled multidimensional arrays (`KeyedArray`) for managing data with explicit axis labels.
  
- `FillArrays`: Provides efficient representations of arrays filled with a single value, useful for initializing data structures.
  
- `DimensionalData`: Facilitates working with multidimensional data, particularly for indexing and slicing along spatial and temporal dimensions.
  
- `NCDatasets`: Provides tools for reading and writing NetCDF files, a common format for scientific data.
  
- `NetCDF`: Re-exported for convenience, enabling users to work with NetCDF files directly.
  
- `YAXArrays`: Supports handling of multidimensional arrays, particularly for managing spatial and temporal data in SINDBAD experiments.
  
- `Zarr`: Re-exported for handling hierarchical, chunked, and compressed data arrays, useful for large datasets.
  
- `YAXArrayBase`: Provides base functionality for working with YAXArrays.
  

**Included Files:**
1. **`utilsData.jl`**:
  - Contains utility functions for data preprocessing, including cleaning, masking, and checking bounds.
    
  
2. **`spatialSubset.jl`**:
  - Implements spatial operations, such as extracting subsets of data based on spatial dimensions.
    
  
3. **`getForcing.jl`**:
  - Provides functions for extracting and processing forcing data, such as environmental drivers, for SINDBAD experiments.
    
  
4. **`getObservation.jl`**:
  - Implements utilities for reading and processing observational data, enabling model validation and performance evaluation.
    
  

**Notes:**
- The package re-exports key packages (`NetCDF`, `YAXArrays`, `Zarr`) for convenience, allowing users to access their functionality directly through `SindbadData`.
  
- Designed to handle large datasets efficiently, leveraging chunked and compressed data formats like NetCDF and Zarr.
  
- Ensures compatibility with SINDBAD&#39;s experimental framework by integrating spatial and temporal data management tools.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/SindbadData.jl#L1-L39" target="_blank" rel="noreferrer">source</a></Badge>

</details>


## Exported {#Exported}


<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.AllNaN' href='#SindbadData.AllNaN'><span class="jlbinding">SindbadData.AllNaN</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



```julia
AllNaN <: YAXArrays.DAT.ProcFilter
```


Specialized filter for YAXArrays to skip pixels with all `NaN` or `missing` values.

**Description**

This struct is used as a specialized filter in data processing pipelines to identify or handle cases where all values in a data segment are NaN (Not a Number).


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/utilsData.jl#L7-L14" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.getForcing-Tuple{NamedTuple}' href='#SindbadData.getForcing-Tuple{NamedTuple}'><span class="jlbinding">SindbadData.getForcing</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getForcing(info::NamedTuple)
```


Reads forcing data from the `data_path` specified in the experiment configuration and returns a NamedTuple with the forcing data.

**Arguments:**
- `info`: A SINDBAD NamedTuple containing all information needed for setup and execution of an experiment.
  

**Returns:**
- A NamedTuple `forcing` containing:
  - `data`: The processed input cubes.
    
  - `dims`: The dimensions of the forcing data.
    
  - `variables`: The names of the forcing variables.
    
  - `f_types`: The types of the forcing data (e.g., `ForcingWithTime` or `ForcingWithoutTime`).
    
  - `helpers`: Helper information for the forcing data.
    
  

**Notes:**
- Reads forcing data from the specified data path and processes it using the SINDBAD framework.
  
- Handles spatiotemporal and spatial-only forcing data.
  
- Applies masks and subsets to the forcing data if specified in the configuration.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/getForcing.jl#L119-L139" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.getNumberOfTimeSteps-Tuple{Any, Any}' href='#SindbadData.getNumberOfTimeSteps-Tuple{Any, Any}'><span class="jlbinding">SindbadData.getNumberOfTimeSteps</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getNumberOfTimeSteps(incubes, time_name)
```


Returns the number of time steps in the input data cubes.

**Arguments**
- `incubes`: Input data cubes containing temporal information
  
- `time_name`: Name of the time dimension/variable
  

**Returns**

Integer representing the total number of time steps in the data


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/utilsData.jl#L206-L217" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.getObservation-Tuple{NamedTuple, NamedTuple}' href='#SindbadData.getObservation-Tuple{NamedTuple, NamedTuple}'><span class="jlbinding">SindbadData.getObservation</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getObservation(info::NamedTuple, forcing_helpers::NamedTuple)
```


Processes observation data and returns a NamedTuple containing the observation data, dimensions, and variables.

**Arguments:**
- `info`: A SINDBAD NamedTuple containing all information needed for setup and execution of an experiment.
  
- `forcing_helpers`: A SINDBAD NamedTuple containing helper information for forcing data.
  

**Returns:**
- A NamedTuple with the following fields:
  - `data`: The processed observation data as an input array.
    
  - `dims`: The dimensions of the observation data.
    
  - `variables`: A tuple of variable names for the observation data.
    
  

**Notes:**
- Reads observation data from the path specified in the experiment configuration.
  
- Handles quality flags, uncertainty, spatial weights, and selection masks for each observation variable.
  
- Subsets and harmonizes the observation data based on the target dimensions and masks.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/getObservation.jl#L80-L99" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.getSpatialSubset-Tuple{Any, Any}' href='#SindbadData.getSpatialSubset-Tuple{Any, Any}'><span class="jlbinding">SindbadData.getSpatialSubset</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getSpatialSubset(ss, v)
```


Extracts a spatial subset of data based on specified spatial subsetting type/strategy.

**Arguments**
- `ss`: Spatial subset parameters or geometry defining the region of interest
  
- `v`: Data to be spatially subset
  

**Returns**

Spatially subset data according to the specified parameters

**Note**

The function assumes input data and spatial parameters are in compatible formats


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/spatialSubset.jl#L3-L17" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.mapCleanData-Union{Tuple{T}, Tuple{Any, Any, Any, Any, Any, Val{T}}} where T' href='#SindbadData.mapCleanData-Union{Tuple{T}, Tuple{Any, Any, Any, Any, Any, Val{T}}} where T'><span class="jlbinding">SindbadData.mapCleanData</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



Maps and cleans data based on quality control parameters and fills missing values.

**Arguments**
- `_data`: Raw input data to be cleaned
  
- `_data_qc`: Quality control data corresponding to input data
  
- `_data_fill`: Fill values for replacing invalid/missing data
  
- `bounds_qc`: Quality control bounds/thresholds
  
- `_data_info`: Additional information about the data
  
- `::Val{T}`: Value type parameter for dispatch
  

**Returns**

Cleaned and mapped data with invalid values replaced according to QC criteria

**Note**

This function performs quality control checks and data cleaning based on the provided bounds and fill values. The exact behavior depends on the value type T.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/utilsData.jl#L360-L377" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.subsetAndProcessYax-Union{Tuple{num_type}, Tuple{Any, Any, Any, Any, Any, Val{num_type}}} where num_type' href='#SindbadData.subsetAndProcessYax-Union{Tuple{num_type}, Tuple{Any, Any, Any, Any, Any, Val{num_type}}} where num_type'><span class="jlbinding">SindbadData.subsetAndProcessYax</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
subsetAndProcessYax(yax, forcing_mask, tar_dims, _data_info, info, ::Val{num_type}; clean_data=true, fill_nan=false, yax_qc=nothing, bounds_qc=nothing) where {num_type}
```


Subset and process YAX data according to specified parameters and quality control criteria.

**Arguments**
- `yax`: YAX data to be processed
  
- `forcing_mask`: Mask to apply to the data
  
- `tar_dims`: Target dimensions
  
- `_data_info`: Data information
  
- `info`: a SINDBAD NT that includes all information needed for setup and execution of an experiment
  
- `::Val{num_type}`: Value type parameter for numerical type specification
  
- `clean_data=true`: Boolean flag to enable/disable data cleaning
  
- `fill_nan=false`: Boolean flag to control NaN filling
  
- `yax_qc=nothing`: Optional quality control parameters for YAX data
  
- `bounds_qc=nothing`: Optional boundary quality control parameters
  

**Returns**

Processed and subset YAX data according to specified parameters and quality controls.

**Type Parameters**
- `num_type`: Numerical type specification for the processed data
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/utilsData.jl#L388-L410" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.toDimStackArray-Tuple{Any, Any, Any}' href='#SindbadData.toDimStackArray-Tuple{Any, Any, Any}'><span class="jlbinding">SindbadData.toDimStackArray</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



Convert a stacked array into a DimensionalArray with specified dimensions and metadata.

**Arguments**
- `stackArr`: The input stacked array to be converted
  
- `time_interval`: Time interval information for temporal dimension
  
- `p_names`: Names of pools/variables
  
- `name`: Optional keyword argument to specify the name of the dimension (default: :pools)
  

**Returns**

A DimensionalArray with proper dimensions and labels.

This function is useful for converting raw stacked arrays into properly dimensioned arrays with metadata, particularly for time series data with multiple pools or variables.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/utilsData.jl#L467-L481" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.yaxCubeToKeyedArray-Tuple{Any}' href='#SindbadData.yaxCubeToKeyedArray-Tuple{Any}'><span class="jlbinding">SindbadData.yaxCubeToKeyedArray</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
yaxCubeToKeyedArray(c)
```


Convert a YAXArray cube to a KeyedArray.

**Arguments**
- `c`: YAXArray input cube to be converted
  

**Returns**

KeyedArray representation of the input YAXArray cube

**Description**

Transforms a YAXArray data cube into a KeyedArray format, preserving the dimensional structure and associated metadata of the original cube.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/utilsData.jl#L447-L461" target="_blank" rel="noreferrer">source</a></Badge>

</details>


## Internal {#Internal}


<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.applyQCBound-NTuple{4, Any}' href='#SindbadData.applyQCBound-NTuple{4, Any}'><span class="jlbinding">SindbadData.applyQCBound</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
applyQCBound(_data, data_qc, bounds_qc, _data_fill)
```


Apply quality control bounds to data values.

**Arguments**
- `_data`: Input data array to be quality controlled
  
- `data_qc`: Quality control flags associated with the data
  
- `bounds_qc`: Bounds/thresholds for quality control checks
  
- `_data_fill`: Fill value to use for data points that fail QC
  

**Returns**

The quality controlled data array with values outside bounds replaced by fill value


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/utilsData.jl#L18-L31" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.applyUnitConversion' href='#SindbadData.applyUnitConversion'><span class="jlbinding">SindbadData.applyUnitConversion</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
applyUnitConversion(_data, conversion, isadditive=false)
```


Applies a simple factor to the input, either additively or multiplicatively depending on isadditive flag

**Arguments**
- `_data`: Input data to be converted
  
- `conversion`: Conversion factor or function to be applied
  
- `isadditive`: Boolean flag indicating whether the conversion is additive (default: false) or multiplicative
  

**Returns**

Converted data with the applied unit transformation


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/utilsData.jl#L41-L53" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.cleanData-Union{Tuple{T}, Tuple{Any, Any, Any, Val{T}}} where T' href='#SindbadData.cleanData-Union{Tuple{T}, Tuple{Any, Any, Any, Val{T}}} where T'><span class="jlbinding">SindbadData.cleanData</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
cleanData(_data, _data_fill, _data_info, ::Val{T}) where {T}
```


Applies a series of cleaning steps to the data, including replacing invalid data, applying unit conversion, and clamping to bounds.

**Arguments**
- `_data`: The raw data to be cleaned
  
- `_data_fill`: Fill values or parameters for handling missing/invalid data
  
- `_data_info`: Information about the data structure and cleaning requirements
  
- `::Val{T}`: Value type parameter for dispatch
  

**Returns**

Cleaned data according to the specified type parameter T


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/utilsData.jl#L65-L78" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.collectForcingHelpers-Tuple{Any, Any, Any}' href='#SindbadData.collectForcingHelpers-Tuple{Any, Any, Any}'><span class="jlbinding">SindbadData.collectForcingHelpers</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
collectForcingHelpers(info, f_sizes, f_dimensions)
```


Generates a NamedTuple of helper information for forcing data.

**Arguments:**
- `info`: A SINDBAD NamedTuple containing all information needed for setup and execution of an experiment.
  
- `f_sizes`: A NamedTuple containing the sizes of forcing dimensions.
  
- `f_dimensions`: A NamedTuple containing the dimensions of the forcing data.
  

**Returns:**
- A NamedTuple `f_helpers` containing helper information for forcing data.
  

**Notes:**
- Includes dimensions, axes, subset information, and sizes for the forcing data.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/getForcing.jl#L37-L52" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.collectForcingSizes-Tuple{Any, Any}' href='#SindbadData.collectForcingSizes-Tuple{Any, Any}'><span class="jlbinding">SindbadData.collectForcingSizes</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
collectForcingSizes(info, in_yax)
```


Collects the sizes of forcing dimensions from the input YAXArray.

**Arguments:**
- `info`: A SINDBAD NamedTuple containing all information needed for setup and execution of an experiment.
  
- `in_yax`: The input YAXArray containing forcing data.
  

**Returns:**
- A NamedTuple `f_sizes` where each dimension name is paired with its size.
  

**Notes:**
- The function retrieves the size of the time dimension and spatial dimensions specified in the experiment configuration.
  
- If the dimension is not directly accessible, it uses `DimensionalData.lookup` to retrieve the size.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/getForcing.jl#L3-L18" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.createForcingNamedTuple-NTuple{4, Any}' href='#SindbadData.createForcingNamedTuple-NTuple{4, Any}'><span class="jlbinding">SindbadData.createForcingNamedTuple</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
createForcingNamedTuple(incubes, f_sizes, f_dimensions, info)
```


Creates a NamedTuple containing forcing data and metadata.

**Arguments:**
- `incubes`: A collection of input cubes (YAXArray) containing forcing data.
  
- `f_sizes`: A NamedTuple containing the sizes of forcing dimensions.
  
- `f_dimensions`: A NamedTuple containing the dimensions of the forcing data.
  
- `info`: A SINDBAD NamedTuple containing all information needed for setup and execution of an experiment.
  

**Returns:**
- A NamedTuple `forcing` containing:
  - `data`: The processed input cubes.
    
  - `dims`: The dimensions of the forcing data.
    
  - `variables`: The names of the forcing variables.
    
  - `f_types`: The types of the forcing data (e.g., `ForcingWithTime` or `ForcingWithoutTime`).
    
  - `helpers`: Helper information for the forcing data.
    
  

**Notes:**
- Processes the input cubes to determine their types and dimensions.
  
- Helper information is generated using `collectForcingHelpers`.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/getForcing.jl#L66-L88" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.getAllConstraintData-NTuple{7, Any}' href='#SindbadData.getAllConstraintData-NTuple{7, Any}'><span class="jlbinding">SindbadData.getAllConstraintData</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getAllConstraintData(nc, data_backend, data_path, default_info, v_info, data_sub_field, info; yax=nothing, use_data_sub=true)
```


Reads data from the observation file and returns the data, YAXArray, variable info, and bounds for the observation constraint.

**Arguments:**
- `nc`: The file or NetCDF object containing the observation data.
  
- `data_backend`: The backend used to process the data (e.g., NetCDF, Zarr).
  
- `data_path`: The path to the observation data file.
  
- `default_info`: Default variable information for constraints.
  
- `v_info`: Variable-specific information for the observation constraint, which can overwrite `default_info`.
  
- `data_sub_field`: The subfield of the observation data to process (e.g., `:data`, `:qflag`, `:unc`).
  
- `info`: A SINDBAD NamedTuple containing all information needed for setup and execution of an experiment.
  
- `yax`: (Optional) The base observation YAXArray.
  
- `use_data_sub`: A flag indicating whether to use the subfield of the observation constraint.
  

**Returns:**
- `nc_sub`: The NetCDF object for the subfield.
  
- `yax_sub`: The YAXArray for the subfield.
  
- `v_info_sub`: The variable information for the subfield.
  
- `bounds_sub`: The bounds for the subfield.
  

**Notes:**
- If the subfield is not provided or `use_data_sub` is `false`, default values are used.
  
- Handles quality flags, uncertainty, spatial weights, and selection masks for observation constraints.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/getObservation.jl#L3-L28" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.getDataDims-Tuple{Any, Any}' href='#SindbadData.getDataDims-Tuple{Any, Any}'><span class="jlbinding">SindbadData.getDataDims</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getDataDims(c, mappinginfo)
```


Retrieves the dimensions of data based on provided mapping information.

**Arguments**
- `c`: The container or data structure to get dimensions from
  
- `mappinginfo`: Information about how the data is mapped
  

**Returns**

The dimensions of the data specified by the mapping information.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/utilsData.jl#L91-L102" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.getDimPermutation-Tuple{Any, Any}' href='#SindbadData.getDimPermutation-Tuple{Any, Any}'><span class="jlbinding">SindbadData.getDimPermutation</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getDimPermutation(datDims, permDims)
```


Returns the permutation indices required to rearrange dimensions from `datDims` to match `permDims`.

**Arguments**
- `datDims`: Array of current dimension names or indices
  
- `permDims`: Array of target dimension names or indices in desired order
  

**Returns**
- Array of indices representing the required permutation
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/utilsData.jl#L111-L121" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.getInputArrayOfType' href='#SindbadData.getInputArrayOfType'><span class="jlbinding">SindbadData.getInputArrayOfType</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getInputArrayOfType(input_data, <: SindbadInputDataType)
```


Converts the provided input data into a specific input array type.

**Arguments**
- `input_data`: The data to be converted into an input array
  
- &lt;: SindbadInputDataType: The specific input array type to convert the data into
  - `::InputArray`: Specifies the input array type as a simple array
    
  - `::InputKeyedArray`: Specifies the input array type as a keyed array
    
  - `::InputNamedDimsArray`: Specifies the input array type as a named dims array
    
  - `::InputYaxArray`: Specifies the input array type as a YAX array
    
  

**Returns**

Returns the input data converted to the specified input array type.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/utilsData.jl#L134-L149" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.getSindbadDims-Tuple{Any}' href='#SindbadData.getSindbadDims-Tuple{Any}'><span class="jlbinding">SindbadData.getSindbadDims</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getSindbadDims(c)
```


prepare the dimensions of data and name them appropriately for use in internal SINDBAD functions

**Arguments**
- `c`: input data cube
  

**Returns**

Dimensions for use in SINDBAD


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/utilsData.jl#L180-L190" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.getTargetDimensionOrder-Tuple{Any}' href='#SindbadData.getTargetDimensionOrder-Tuple{Any}'><span class="jlbinding">SindbadData.getTargetDimensionOrder</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getTargetDimensionOrder(info)
```


Retrieves the target dimension order to organize the forcing data from the provided information.

**Arguments**
- `info`: Input information containing dimension order details.
  

**Returns**

The ordered sequence of dimensions for the target.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/utilsData.jl#L224-L234" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.getYaxFromSource' href='#SindbadData.getYaxFromSource'><span class="jlbinding">SindbadData.getYaxFromSource</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getYaxFromSource(nc, data_path, data_path_v, source_variable, info, <: DataFormatBackend)
```


Retrieve the data from a specified source.

**Arguments**
- `nc`: The NetCDF file or object to read data from.
  
- `data_path`: The path to the data within the NetCDF file.
  
- `data_path_v`: The path to the variable within the NetCDF file.
  
- `source_variable`: The name of the source variable to extract data for.
  
- `info`: Additional information or metadata required for processing.
  
- `<: DataFormatBackend`: Specifies the SINDBAD backend being used.
  - `::BackendNetcdf`: Specifies that the function operates on a NetCDF backend.
    
  - `::BackendZarr`: Specifies that the backend being used is Zarr.
    
  

**Returns**
- The file object and extracted YAX data from the specified source.
  

**Notes**
- Ensure that the `nc` object and paths provided are valid and accessible.
  
- The functions are specific to the NetCDF and Zarr backend and may not work with other backends.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/utilsData.jl#L248-L269" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.loadDataFile-Tuple{Any}' href='#SindbadData.loadDataFile-Tuple{Any}'><span class="jlbinding">SindbadData.loadDataFile</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
loadDataFile(data_path::String) -> Any
```


Load data from the specified file path.

**Arguments**
- `data_path::String`: The path to the data file to be loaded.
  

**Returns**
- The data loaded from the specified file. The return type depends on the file format and its contents.
  

**Notes**
- Ensure that the file exists and is accessible at the given path.
  
- The function assumes the file format is supported by the implementation.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/utilsData.jl#L310-L324" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.loadDataFromPath-NTuple{4, Any}' href='#SindbadData.loadDataFromPath-NTuple{4, Any}'><span class="jlbinding">SindbadData.loadDataFromPath</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
loadDataFromPath(nc, data_path, data_path_v, source_variable)
```


Load data from specified NetCDF paths using given parameters.

**Arguments**
- `nc`: NetCDF file handle
  
- `data_path`: Path to the main data in NetCDF file
  
- `data_path_v`: Path to the variable data in NetCDF file
  
- `source_variable`: Name of the source variable to load
  

**Returns**

Data loaded from the specified paths in the NetCDF file.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/utilsData.jl#L336-L349" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadData.spatialSubset' href='#SindbadData.spatialSubset'><span class="jlbinding">SindbadData.spatialSubset</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
spatialSubset(v, ss_range, <: SpatialSubsetter)
```


Extracts a spatial subset of the input data `v` based on the specified range and spatial dimension.

**Arguments:**
- `v`: The input data from which a spatial subset is to be extracted.
  
- `ss_range`: The range of indices or values to subset along the specified spatial dimension.
  

**Returns:**
- A subset of the input data `v` corresponding to the specified spatial range and dimension.
  

**SpatialSubsetter**

Abstract type for spatial subsetting methods in SINDBAD

**Available methods/subtypes:**
- `SpaceID`: Use site ID (all caps) for spatial subsetting 
  
- `SpaceId`: Use site ID (capitalized) for spatial subsetting 
  
- `Spaceid`: Use site ID for spatial subsetting 
  
- `Spacelat`: Use latitude for spatial subsetting 
  
- `Spacelatitude`: Use full latitude for spatial subsetting 
  
- `Spacelon`: Use longitude for spatial subsetting 
  
- `Spacelongitude`: Use full longitude for spatial subsetting 
  
- `Spacesite`: Use site location for spatial subsetting 
  


---


**Extended help**

**Notes:**
- The function dynamically selects the appropriate field in `v` based on the spatial type provided.
  
- The spatial type determines the field name (e.g., `site`, `lat`, `longitude`, `id`, etc.) used for subsetting.
  

**Examples:**
1. **Subsetting by latitude**:
  

```julia
subset = spatialSubset(data, 10:20, Spacelat())
```

1. **Subsetting by longitude**:
  

```julia
subset = spatialSubset(data, 30:40, Spacelongitude())
```

1. **Subsetting by site ID**:
  

```julia
subset = spatialSubset(data, 1:5, Spaceid())
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/EarthyScience/SINDBAD/blob/ee03139c9d1d3835a3116d469c990f996f6f20c0/lib/SindbadData/src/spatialSubset.jl#L36-L73" target="_blank" rel="noreferrer">source</a></Badge>

</details>

