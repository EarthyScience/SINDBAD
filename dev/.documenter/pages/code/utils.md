<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.SindbadUtils' href='#SindbadUtils.SindbadUtils'><span class="jlbinding">SindbadUtils.SindbadUtils</span></a> <Badge type="info" class="jlObjectType jlModule" text="Module" /></summary>



```julia
SindbadUtils
```


The `SindbadUtils` package provides a collection of utility functions and tools for handling data, managing NamedTuples, and performing spatial and temporal operations in the SINDBAD framework. It serves as a foundational package for simplifying common tasks and ensuring consistency across SINDBAD experiments.

**Purpose:**

This package is designed to provide reusable utilities for data manipulation, statistical operations, and spatial/temporal processing. 

**Dependencies:**
- `Sindbad`: Provides the core SINDBAD models and types.
  
- `Crayons`: Enables colored terminal output, improving the readability of logs and messages.
  
- `StyledStrings`: Provides styled text for enhanced terminal output.
  
- `Dates`: Facilitates date and time operations, useful for temporal data processing.
  
- `FIGlet`: Generates ASCII art text, useful for creating visually appealing headers in logs or outputs.
  
- `Logging`: Provides logging utilities for debugging and monitoring SINDBAD workflows.
  

**Included Files:**
1. **`getArrayView.jl`**:
  - Implements functions for creating views of arrays, enabling efficient data slicing and subsetting.
    
  
2. **`utils.jl`**:
  - Contains general-purpose utility functions for data manipulation and processing.
    
  
3. **`utilsNT.jl`**:
  - Provides utilities for working with NamedTuples, including transformations and access operations.
    
  
4. **`utilsTemporal.jl`**:
  - Handles temporal operations, including time-based filtering and aggregation.
    
  

</details>


## Exported {#Exported}


<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.addPackage-Tuple{Any, Any}' href='#SindbadUtils.addPackage-Tuple{Any, Any}'><span class="jlbinding">SindbadUtils.addPackage</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
addPackage(where_to_add, the_package_to_add)
```


Adds a specified Julia package to the environment of a given module or project.

**Arguments:**
- `where_to_add`: The module or project where the package should be added.
  
- `the_package_to_add`: The name of the package to add.
  

**Behavior:**
- Activates the environment of the specified module or project.
  
- Checks if the package is already installed in the environment.
  
- If the package is not installed:
  - Adds the package to the environment.
    
  - Removes the `Manifest.toml` file and reinstantiates the environment to ensure consistency.
    
  - Provides instructions for importing the package in the module.
    
  
- Restores the original environment after the operation.
  

**Notes:**
- This function assumes that the `where_to_add` module or project is structured with a standard Julia project layout.
  
- It requires the `Pkg` module for package management, which is re-exported from core Sindbad.
  

**Example:**

```julia
addPackage(MyModule, "DataFrames")
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.booleanizeArray-Tuple{Any}' href='#SindbadUtils.booleanizeArray-Tuple{Any}'><span class="jlbinding">SindbadUtils.booleanizeArray</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
booleanizeArray(_array)
```


Converts an array into a boolean array where elements greater than zero are `true`.

**Arguments:**
- `_array`: The input array to be converted.
  

**Returns:**

A boolean array with the same dimensions as `_array`.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.createTimeAggregator' href='#SindbadUtils.createTimeAggregator'><span class="jlbinding">SindbadUtils.createTimeAggregator</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
createTimeAggregator(date_vector, t_step, aggr_func = mean, skip_aggregation = false)
```


a function to create a temporal aggregation struct for a given time step 

**Arguments:**
- `date_vector`: a vector of datetime objects that determine the index of the array to be aggregated
  
- `t_step`: a string/Symbol/Type defining the aggregation time target with different types as follows:
  - `::Union{String, Symbol}`: a string/Symbol defining the aggregation time target from the settings
    
  
- `aggr_func`: a function to use for aggregation, defaults to mean
  
- `skip_aggregation`: a flag indicating if the aggregation target is the same as the input data and the aggregation can be skipped, defaults to false
  

**Returns:**
- `::Vector{TimeAggregator}`: a vector of TimeAggregator structs
  

**t_step:**

**TimeAggregation**

Abstract type for time aggregation methods in SINDBAD

**Available methods/subtypes:**
- `TimeAllYears`: aggregation/slicing to include all years 
  
- `TimeArray`: use array-based time aggregation 
  
- `TimeDay`: aggregation to daily time steps 
  
- `TimeDayAnomaly`: aggregation to daily anomalies 
  
- `TimeDayIAV`: aggregation to daily IAV 
  
- `TimeDayMSC`: aggregation to daily MSC 
  
- `TimeDayMSCAnomaly`: aggregation to daily MSC anomalies 
  
- `TimeDiff`: aggregation to time differences, e.g. monthly anomalies 
  
- `TimeFirstYear`: aggregation/slicing of the first year 
  
- `TimeHour`: aggregation to hourly time steps 
  
- `TimeHourAnomaly`: aggregation to hourly anomalies 
  
- `TimeHourDayMean`: aggregation to mean of hourly data over days 
  
- `TimeIndexed`: aggregation using time indices, e.g., TimeFirstYear 
  
- `TimeMean`: aggregation to mean over all time steps 
  
- `TimeMonth`: aggregation to monthly time steps 
  
- `TimeMonthAnomaly`: aggregation to monthly anomalies 
  
- `TimeMonthIAV`: aggregation to monthly IAV 
  
- `TimeMonthMSC`: aggregation to monthly MSC 
  
- `TimeMonthMSCAnomaly`: aggregation to monthly MSC anomalies 
  
- `TimeNoDiff`: aggregation without time differences 
  
- `TimeRandomYear`: aggregation/slicing of a random year 
  
- `TimeShuffleYears`: aggregation/slicing/selection of shuffled years 
  
- `TimeSizedArray`: aggregation to a sized array 
  
- `TimeYear`: aggregation to yearly time steps 
  
- `TimeYearAnomaly`: aggregation to yearly anomalies 
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.dictToNamedTuple-Tuple{AbstractDict}' href='#SindbadUtils.dictToNamedTuple-Tuple{AbstractDict}'><span class="jlbinding">SindbadUtils.dictToNamedTuple</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
dictToNamedTuple(d::AbstractDict)
```


Convert a nested dictionary to a NamedTuple.

**Arguments**
- `d::AbstractDict`: The input dictionary to convert
  

**Returns**
- A NamedTuple with the same structure as the input dictionary
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.doNothing-Tuple{Any}' href='#SindbadUtils.doNothing-Tuple{Any}'><span class="jlbinding">SindbadUtils.doNothing</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
doNothing(dat)
```


Returns the input as is, without any modifications.

**Arguments:**
- `dat`: The input data.
  

**Returns:**

The same input data.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.doTemporalAggregation' href='#SindbadUtils.doTemporalAggregation'><span class="jlbinding">SindbadUtils.doTemporalAggregation</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
doTemporalAggregation(dat, temporal_aggregators, aggregation_type)
```


a temporal aggregation function to aggregate the data using a vector of aggregators

**Arguments:**
- `dat`: a data array/vector to aggregate
  
- `temporal_aggregators`: a vector of time aggregator structs with indices and function to do aggregation
  
- aggregation_type: a type defining the type of aggregation to be done as follows:
  - `::TimeNoDiff`: a type defining that the aggregator does not require removing/reducing values from original time series
    
  - `::TimeDiff`: a type defining that the aggregator requires removing/reducing values from original time series. First aggregator aggregates the main time series, second aggregator aggregates to the time series to be removed.
    
  - `::TimeIndexed`: a type defining that the aggregator requires indexing the original time series
    
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.dropFields-Tuple{NamedTuple, Tuple{Vararg{Symbol}}}' href='#SindbadUtils.dropFields-Tuple{NamedTuple, Tuple{Vararg{Symbol}}}'><span class="jlbinding">SindbadUtils.dropFields</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
dropFields(namedtuple::NamedTuple, names::Tuple{Vararg{Symbol}})
```


Remove specified fields from a NamedTuple.

**Arguments**
- `namedtuple`: The input NamedTuple
  
- `names`: A tuple of field names to remove
  

**Returns**
- A new NamedTuple with the specified fields removed
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.entertainMe' href='#SindbadUtils.entertainMe'><span class="jlbinding">SindbadUtils.entertainMe</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
entertainMe(n=10, disp_text="SINDBAD")
```


Displays the given text `disp_text` as a banner `n` times.

**Arguments:**
- `n`: Number of times to display the banner (default: 10).
  
- `disp_text`: The text to display (default: &quot;SINDBAD&quot;).
  
- `c_olor`: Whether to display the text in random colors (default: `false`).
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.foldlUnrolled-Union{Tuple{N}, Tuple{Any, NTuple{N, Any}}} where N' href='#SindbadUtils.foldlUnrolled-Union{Tuple{N}, Tuple{Any, NTuple{N, Any}}} where N'><span class="jlbinding">SindbadUtils.foldlUnrolled</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
foldlUnrolled(f, x::Tuple{Vararg{Any, N}}; init)
```


Generate an unrolled expression to run a function for each element of a tuple to avoid complexity of for loops  for compiler.

**Arguments**
- `f`: The function to apply
  
- `x`: The tuple to iterate through
  
- `init`: Initial value for the fold operation
  

**Returns**
- The result of applying the function to each element
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.getAbsDataPath-Tuple{Any, Any}' href='#SindbadUtils.getAbsDataPath-Tuple{Any, Any}'><span class="jlbinding">SindbadUtils.getAbsDataPath</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getAbsDataPath(info, data_path)
```


Converts a relative data path to an absolute path based on the experiment directory.

**Arguments:**
- `info`: The SINDBAD experiment information object.
  
- `data_path`: The relative or absolute data path.
  

**Returns:**

An absolute data path.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.getArrayView' href='#SindbadUtils.getArrayView'><span class="jlbinding">SindbadUtils.getArrayView</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getArrayView(_dat::AbstractArray{<:Any, N}, inds::Tuple{Vararg{Int}}) where N
```


Creates a view of the input array `_dat` based on the provided indices tuple `inds`.

**Arguments:**
- `_dat`: The input array from which a view is created. Can be of any dimensionality.
  
- `inds`: A tuple of integer indices specifying the spatial or temporal dimensions to slice.
  

**Returns:**
- A `SubArray` view of `_dat` corresponding to the specified indices.
  

**Notes:**
- The function supports arrays of arbitrary dimensions (`N`).
  
- For arrays with fewer dimensions than the size of `inds`, an error is thrown.
  
- For higher-dimensional arrays, the indices are applied to the last dimensions, while earlier dimensions are accessed using `Colon()` (i.e., all elements are included).
  
- This function avoids copying data by creating a view, which is efficient for large arrays.
  

**Error Handling:**
- Throws an error if the dimensionality of `_dat` is less than the size of `inds`.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.getCombinedNamedTuple-Tuple{NamedTuple, NamedTuple}' href='#SindbadUtils.getCombinedNamedTuple-Tuple{NamedTuple, NamedTuple}'><span class="jlbinding">SindbadUtils.getCombinedNamedTuple</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getCombinedNamedTuple(base_nt::NamedTuple, priority_nt::NamedTuple)
```


Combine property values from base and priority NamedTuples.

**Arguments**
- `base_nt`: The base NamedTuple
  
- `priority_nt`: The priority NamedTuple whose values take precedence
  

**Returns**
- A new NamedTuple combining values from both inputs
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.getNamedTupleFromTable-Tuple{Any}' href='#SindbadUtils.getNamedTupleFromTable-Tuple{Any}'><span class="jlbinding">SindbadUtils.getNamedTupleFromTable</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getNamedTupleFromTable(tbl; replace_missing_values=false)
```


Convert a table to a NamedTuple.

**Arguments**
- `tbl`: The input table
  
- `replace_missing_values`: Whether to replace missing values with empty strings
  

**Returns**
- A NamedTuple representation of the table
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.getSindbadDataDepot-Tuple{}' href='#SindbadUtils.getSindbadDataDepot-Tuple{}'><span class="jlbinding">SindbadUtils.getSindbadDataDepot</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getSindbadDataDepot(; env_data_depot_var="SINDBAD_DATA_DEPOT", local_data_depot="../data")
```


Retrieve the Sindbad data depot path.

**Arguments**
- `env_data_depot_var`: Environment variable name for the data depot (default: &quot;SINDBAD_DATA_DEPOT&quot;)
  
- `local_data_depot`: Local path to the data depot (default: &quot;../data&quot;)
  

**Returns**

The path to the Sindbad data depot.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.getTimeAggregatorTypeInstance' href='#SindbadUtils.getTimeAggregatorTypeInstance'><span class="jlbinding">SindbadUtils.getTimeAggregatorTypeInstance</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getTimeAggregatorTypeInstance(aggr)
```


Creates and returns a time aggregator instance based on the provided aggregation.

**Arguments**
- `aggr::Symbol`: Symbol specifying the type of time aggregation to be performed
  
- `aggr::String`: String specifying the type of time aggregation to be performed
  

**Returns**

An instance of the corresponding time aggregator type.

**Notes:**
- A similar approach `getTypeInstanceForNamedOptions` is used in `SindbadSetup` for creating types of other named option
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.getTupleFromLongTuple-Tuple{Any}' href='#SindbadUtils.getTupleFromLongTuple-Tuple{Any}'><span class="jlbinding">SindbadUtils.getTupleFromLongTuple</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getTupleFromLongTuple(long_tuple)
```


Convert a LongTuple to a regular tuple.

**Arguments**
- `long_tuple`: The input LongTuple
  

**Returns**
- A regular tuple containing all elements from the LongTuple
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.makeLongTuple' href='#SindbadUtils.makeLongTuple'><span class="jlbinding">SindbadUtils.makeLongTuple</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
makeLongTuple(normal_tuple; longtuple_size=5)
```


**Arguments:**
- `normal_tuple`: a normal tuple
  
- `longtuple_size`: size to break down the tuple into
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.makeLongTuple-2' href='#SindbadUtils.makeLongTuple-2'><span class="jlbinding">SindbadUtils.makeLongTuple</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
makeLongTuple(normal_tuple; longtuple_size=5)
```


Create a LongTuple from a normal tuple.

**Arguments**
- `normal_tuple`: The input tuple to convert
  
- `longtuple_size`: Size to break down the tuple into (default: 5)
  

**Returns**
- A LongTuple containing the elements of the input tuple
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.makeNamedTuple-Tuple{Any, Any}' href='#SindbadUtils.makeNamedTuple-Tuple{Any, Any}'><span class="jlbinding">SindbadUtils.makeNamedTuple</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
makeNamedTuple(input_data, input_names)
```


Create a NamedTuple from input data and names.

**Arguments**
- `input_data`: Vector of data values
  
- `input_names`: Vector of names for the fields
  

**Returns**
- A NamedTuple with the specified names and values
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.mergeNamedTuple-Tuple{Any, Any}' href='#SindbadUtils.mergeNamedTuple-Tuple{Any, Any}'><span class="jlbinding">SindbadUtils.mergeNamedTuple</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



Merges algorithm options by combining default options with user-provided options.

This function takes two option dictionaries and combines them, with user options taking precedence over default options.

**Arguments**
- `def_o`: Default options object (NamedTuple/Struct/Dictionary) containing baseline algorithm parameters
  
- `u_o`: User options object containing user-specified overrides
  

**Returns**
- A merged object containing the combined algorithm options
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.nonUnique-Union{Tuple{AbstractArray{T}}, Tuple{T}} where T' href='#SindbadUtils.nonUnique-Union{Tuple{AbstractArray{T}}, Tuple{T}} where T'><span class="jlbinding">SindbadUtils.nonUnique</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
nonUnique(x::AbstractArray{T}) where T
```


Finds and returns a vector of duplicate elements in the input array.

**Arguments:**
- `x`: The input array.
  

**Returns:**

A vector of duplicate elements.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.removeEmptyTupleFields-Tuple{NamedTuple}' href='#SindbadUtils.removeEmptyTupleFields-Tuple{NamedTuple}'><span class="jlbinding">SindbadUtils.removeEmptyTupleFields</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
removeEmptyTupleFields(tpl::NamedTuple)
```


Remove all empty fields from a NamedTuple.

**Arguments**
- `tpl`: The input NamedTuple
  

**Returns**
- A new NamedTuple with empty fields removed
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.replaceInvalid-Tuple{Any, Any}' href='#SindbadUtils.replaceInvalid-Tuple{Any, Any}'><span class="jlbinding">SindbadUtils.replaceInvalid</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
replaceInvalid(_data, _data_fill)
```


Replaces invalid numbers in the input with a specified fill value.

**Arguments:**
- `_data`: The input number.
  
- `_data_fill`: The value to replace invalid numbers with.
  

**Returns:**

The input number if valid, otherwise the fill value.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.setLogLevel-Tuple{Symbol}' href='#SindbadUtils.setLogLevel-Tuple{Symbol}'><span class="jlbinding">SindbadUtils.setLogLevel</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
setLogLevel(log_level::Symbol)
```


Sets the logging level to the specified level.

**Arguments:**
- `log_level`: The desired logging level (`:debug`, `:warn`, `:error`).
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.setLogLevel-Tuple{}' href='#SindbadUtils.setLogLevel-Tuple{}'><span class="jlbinding">SindbadUtils.setLogLevel</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
setLogLevel()
```


Sets the logging level to `Info`.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.setTupleField-Tuple{NamedTuple, Tuple{Symbol, Any}}' href='#SindbadUtils.setTupleField-Tuple{NamedTuple, Tuple{Symbol, Any}}'><span class="jlbinding">SindbadUtils.setTupleField</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
setTupleField(tpl, vals)
```


Set a field in a NamedTuple.

**Arguments**
- `tpl`: The input NamedTuple
  
- `vals`: Tuple containing field name and value
  

**Returns**
- A new NamedTuple with the updated field
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.setTupleSubfield-Tuple{NamedTuple, Symbol, Tuple{Symbol, Any}}' href='#SindbadUtils.setTupleSubfield-Tuple{NamedTuple, Symbol, Tuple{Symbol, Any}}'><span class="jlbinding">SindbadUtils.setTupleSubfield</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
setTupleSubfield(tpl, fieldname, vals)
```


Set a subfield of a NamedTuple.

**Arguments**
- `tpl`: The input NamedTuple
  
- `fieldname`: The name of the field to set
  
- `vals`: Tuple containing subfield name and value
  

**Returns**
- A new NamedTuple with the updated subfield
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.sindbadBanner' href='#SindbadUtils.sindbadBanner'><span class="jlbinding">SindbadUtils.sindbadBanner</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
sindbadBanner(disp_text="SINDBAD")
```


Displays the given text as a banner using Figlets.

**Arguments:**
- `disp_text`: The text to display (default: &quot;SINDBAD&quot;).
  
- `c_olor`: Whether to display the text in random colors (default: `false`).
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.stackArrays-Tuple{Any}' href='#SindbadUtils.stackArrays-Tuple{Any}'><span class="jlbinding">SindbadUtils.stackArrays</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
stackArrays(arr)
```


Stacks a collection of arrays along the first dimension.

**Arguments:**
- `arr`: A collection of arrays to be stacked. All arrays must have the same size along their non-stacked dimensions.
  

**Returns:**
- A single array where the input arrays are stacked along the first dimension.
  
- If the arrays are 1D, the result is a vector.
  

**Notes:**
- The function uses `hcat` to horizontally concatenate the arrays and then creates a view to stack them along the first dimension.
  
- If the first dimension of the input arrays has a size of 1, the result is flattened into a vector.
  
- This function is efficient and avoids unnecessary data copying.
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.tabularizeList-Tuple{Any}' href='#SindbadUtils.tabularizeList-Tuple{Any}'><span class="jlbinding">SindbadUtils.tabularizeList</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
tabularizeList(_list)
```


Converts a list or tuple into a table using `TypedTables`.

**Arguments:**
- `_list`: The input list or tuple.
  

**Returns:**

A table representation of the input list.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.tcPrint-Tuple{Any}' href='#SindbadUtils.tcPrint-Tuple{Any}'><span class="jlbinding">SindbadUtils.tcPrint</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
tcPrint(d; _color=true, _type=true, _value=true, t_op=true)
```


Print a formatted representation of a data structure with type annotations and colors.

**Arguments**
- `d`: The object to print
  
- `_color`: Whether to use colors (default: true)
  
- `_type`: Whether to show types (default: false)
  
- `_value`: Whether to show values (default: true)
  
- `_tspace`: Starting tab space
  
- `space_pad`: Additional space padding
  

**Returns**
- Nothing (prints to console)
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.toUpperCaseFirst' href='#SindbadUtils.toUpperCaseFirst'><span class="jlbinding">SindbadUtils.toUpperCaseFirst</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
toUpperCaseFirst(s::String, prefix="")
```


Converts the first letter of each word in a string to uppercase, removes underscores, and adds a prefix.

**Arguments:**
- `s`: The input string.
  
- `prefix`: A prefix to add to the resulting string (default: &quot;&quot;).
  

**Returns:**

A `Symbol` with the transformed string.

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.toggleStackTraceNT' href='#SindbadUtils.toggleStackTraceNT'><span class="jlbinding">SindbadUtils.toggleStackTraceNT</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
toggleStackTraceNT(toggle=true)
```


Modifies the display of stack traces to reduce verbosity for NamedTuples.

**Arguments:**
- `toggle`: Whether to enable or disable the modification (default: `true`).
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.valToSymbol-Tuple{Any}' href='#SindbadUtils.valToSymbol-Tuple{Any}'><span class="jlbinding">SindbadUtils.valToSymbol</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
valToSymbol(val)
```


Returns the symbol corresponding to the type of the input value.

**Arguments:**
- `val`: The input value.
  

**Returns:**

A `Symbol` representing the type of the input value.

</details>


## Internal {#Internal}


<details class='jldocstring custom-block' open>
<summary><a id='Base.getindex-Union{Tuple{N}, Tuple{TimeAggregatorViewInstance, Vararg{Int64, N}}} where N' href='#Base.getindex-Union{Tuple{N}, Tuple{TimeAggregatorViewInstance, Vararg{Int64, N}}} where N'><span class="jlbinding">Base.getindex</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
Base.getindex(a::TimeAggregatorViewInstance, I::Vararg{Int, N})
```


extend the getindex function for TimeAggregatorViewInstance type

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Base.size-Tuple{TimeAggregatorViewInstance, Any}' href='#Base.size-Tuple{TimeAggregatorViewInstance, Any}'><span class="jlbinding">Base.size</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
Base.size(a::TimeAggregatorViewInstance, i)
```


extend the size function for TimeAggregatorViewInstance type

</details>

<details class='jldocstring custom-block' open>
<summary><a id='Base.view-Tuple{AbstractArray, TimeAggregator}' href='#Base.view-Tuple{AbstractArray, TimeAggregator}'><span class="jlbinding">Base.view</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
Base.view(x::AbstractArray, v::TimeAggregator; dim = 1)
```


extend the view function for TimeAggregatorViewInstance type

**Arguments:**
- `x`: input array to be viewed
  
- `v`: time aggregator struct with indices and function
  
- `dim`: the dimension along which the aggregation should be done
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.collectColorForTypes-Tuple{Any}' href='#SindbadUtils.collectColorForTypes-Tuple{Any}'><span class="jlbinding">SindbadUtils.collectColorForTypes</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
collectColorForTypes(d; _color = true)
```


Collect colors for all types from nested namedtuples.

**Arguments**
- `d`: The input data structure
  
- `_color`: Whether to use colors (default: true)
  

**Returns**
- A dictionary mapping types to color codes
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.getIndexForSelectedYear-Tuple{Any, Any}' href='#SindbadUtils.getIndexForSelectedYear-Tuple{Any, Any}'><span class="jlbinding">SindbadUtils.getIndexForSelectedYear</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getIndexForSelectedYear(years, sel_year)
```


a helper function to get the indices of the first year from the date vector

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.getIndicesForTimeGroups-Tuple{Any}' href='#SindbadUtils.getIndicesForTimeGroups-Tuple{Any}'><span class="jlbinding">SindbadUtils.getIndicesForTimeGroups</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getIndicesForTimeGroups(groups)
```


a helper function to get the indices of the date group of the time series

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.getTimeAggrArray-Union{Tuple{AbstractArray{<:Any, N}}, Tuple{N}} where N' href='#SindbadUtils.getTimeAggrArray-Union{Tuple{AbstractArray{<:Any, N}}, Tuple{N}} where N'><span class="jlbinding">SindbadUtils.getTimeAggrArray</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getTimeAggrArray(_dat::AbstractArray{T, 2})
```


a helper function to instantiate an array from the TimeAggregatorViewInstance for N-dimensional array

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.getTimeArray-Tuple{Any, TimeSizedArray}' href='#SindbadUtils.getTimeArray-Tuple{Any, TimeSizedArray}'><span class="jlbinding">SindbadUtils.getTimeArray</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getTimeArray(ar, ::TimeSizedArray || ::TimeArray)
```


a helper function to get the array of indices

**Arguments:**
- `ar`: an array of time
  
- array type: a type defining the type of array to be returned
  - `::TimeSizedArray`: indices as static array
    
  - `::TimeArray`: indices as normal array
    
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.getTypeOfTimeIndexArray' href='#SindbadUtils.getTypeOfTimeIndexArray'><span class="jlbinding">SindbadUtils.getTypeOfTimeIndexArray</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
getTypeOfTimeIndexArray(_type=:array)
```


a helper functio to easily switch the array type for indices of the TimeAggregator object

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.getTypes!-Tuple{Any, Any}' href='#SindbadUtils.getTypes!-Tuple{Any, Any}'><span class="jlbinding">SindbadUtils.getTypes!</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getTypes!(d, all_types)
```


Collect all types from nested namedtuples.

**Arguments**
- `d`: The input data structure
  
- `all_types`: Array to store collected types
  

**Returns**
- Array of unique types found in the data structure
  

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.getdim-Union{Tuple{TimeAggregatorViewInstance{<:Any, <:Any, D}}, Tuple{D}} where D' href='#SindbadUtils.getdim-Union{Tuple{TimeAggregatorViewInstance{<:Any, <:Any, D}}, Tuple{D}} where D'><span class="jlbinding">SindbadUtils.getdim</span></a> <Badge type="info" class="jlObjectType jlMethod" text="Method" /></summary>



```julia
getdim(a::TimeAggregatorViewInstance{<:Any, <:Any, D})
```


get the dimension to aggregate for TimeAggregatorViewInstance type

</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.mergeNamedTupleSetValue' href='#SindbadUtils.mergeNamedTupleSetValue'><span class="jlbinding">SindbadUtils.mergeNamedTupleSetValue</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
mergeNamedTupleSetValue(o, p, v)
```


Set a field in an options object.

**Arguments**
- `o`: The options object (NamedTuple or mutable struct)
  
- `p`: The field name to update
  
- `v`: The new value to assign
  

**Variants:**
1. **For `NamedTuple` options**:
  - Updates the field in an immutable `NamedTuple` by creating a new `NamedTuple` with the updated value.
    
  - Uses the `@set` macro for immutability handling.
    
  
2. **For mutable struct options (e.g., BayesOpt)**:
  - Directly updates the field in the mutable struct using `Base.setproperty!`.
    
  

**Returns:**
- The updated options object with the specified field modified.
  

**Notes:**
- This function is used internally by `mergeNamedTuple` to handle field updates in both mutable and immutable options objects.
  
- Ensures compatibility with different types of optimization algorithm configurations.
  

**Examples:**
1. **Updating a `NamedTuple`**:
  

```julia
options = (max_iters = 100, tol = 1e-6)
updated_options = mergeNamedTupleSetValue(options, :tol, 1e-8)
```

1. **Updating a mutable struct**:
  

```julia
mutable struct BayesOptConfig
    max_iters::Int
    tol::Float64
end
config = BayesOptConfig(100, 1e-6)
updated_config = mergeNamedTupleSetValue(config, :tol, 1e-8)
```


</details>

<details class='jldocstring custom-block' open>
<summary><a id='SindbadUtils.temporalAggregation' href='#SindbadUtils.temporalAggregation'><span class="jlbinding">SindbadUtils.temporalAggregation</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
temporalAggregation(dat::AbstractArray, temporal_aggregator::TimeAggregator, dim = 1)
```


a temporal aggregation function to aggregate the data using a given aggregator when the input data is an array

**Arguments:**
- `dat`: a data array/vector to aggregate with function for the following types:
  - `::AbstractArray`: an array
    
  - `::SubArray`: a view of an array
    
  - `::Nothing`: a dummy type to return the input and do no aggregation data
    
  
- `temporal_aggregator`: a time aggregator struct with indices and function to do aggregation
  
- `dim`: the dimension along which the aggregation should be done
  

</details>

