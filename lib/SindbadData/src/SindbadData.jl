"""
    module SindbadData

The `SindbadData` module provides tools for handling and processing SINDBAD-related input data and processing. It supports reading, cleaning, masking, and managing data for SINDBAD experiments, with a focus on spatial and temporal dimensions.

# Purpose:
This module is designed to streamline the ingestion and preprocessing of input data for SINDBAD experiments. 

# Dependencies:
- `SindbadUtils`: Provides utility functions for handling NamedTuple, spatial operations, and other helper tasks for spatial and temporal operations.
- `AxisKeys`: Enables labeled multidimensional arrays (`KeyedArray`) for managing data with explicit axis labels.
- `FillArrays`: Provides efficient representations of arrays filled with a single value, useful for initializing data structures.
- `DimensionalData`: Facilitates working with multidimensional data, particularly for indexing and slicing along spatial and temporal dimensions.
- `NCDatasets`: Provides tools for reading and writing NetCDF files, a common format for scientific data.
- `NetCDF`: Re-exported for convenience, enabling users to work with NetCDF files directly.
- `YAXArrays`: Supports handling of multidimensional arrays, particularly for managing spatial and temporal data in SINDBAD experiments.
- `Zarr`: Re-exported for handling hierarchical, chunked, and compressed data arrays, useful for large datasets.
- `YAXArrayBase`: Provides base functionality for working with YAXArrays.

# Included Files:
1. **`inputTypes.jl`**:
   - Defines types and structures for managing input data, ensuring consistency across SINDBAD experiments.

2. **`utilsData.jl`**:
   - Contains utility functions for data preprocessing, including cleaning, masking, and checking bounds.

3. **`getForcing.jl`**:
   - Provides functions for extracting and processing forcing data, such as environmental drivers, for SINDBAD experiments.

4. **`getObservation.jl`**:
   - Implements utilities for reading and processing observational data, enabling model validation and performance evaluation.

# Notes:
- The module re-exports key packages (`NetCDF`, `YAXArrays`, `Zarr`) for convenience, allowing users to access their functionality directly through `SindbadData`.
- Designed to handle large datasets efficiently, leveraging chunked and compressed data formats like NetCDF and Zarr.
- Ensures compatibility with SINDBAD's experimental framework by integrating spatial and temporal data management tools.

# Examples:
1. **Reading forcing data**:
    ```julia
    using SindbadData

    forcing_data = getForcing("forcing_file.nc")
    ```

2. **Processing observational data**:
    ```julia
    using SindbadData

    observations = getObservation("observation_file.nc")
    ```

3. **Cleaning and masking data**:
    ```julia
    using SindbadData

    cleaned_data = cleanData(raw_data, mask)
    ```
"""
module SindbadData
    using Reexport: @reexport
    using SindbadUtils
    using AxisKeys: KeyedArray, AxisKeys
    using FillArrays
    using DimensionalData
    using NCDatasets
    @reexport using NetCDF
    @reexport using YAXArrays
    @reexport using Zarr
    using YAXArrayBase

    include("inputTypes.jl")
    include("utilsData.jl")
    include("getForcing.jl")
    include("getObservation.jl")
    
end # module SindbadData
