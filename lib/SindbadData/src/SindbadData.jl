"""
    SindbadData

Contains a set of functions to load/clean and output data.
"""
module SindbadData

    using SindbadUtils
    using AxisKeys: KeyedArray, AxisKeys
    using FillArrays
    using DimensionalData
    using NetCDF
    using NCDatasets
    using YAXArrays
    using Zarr
    using YAXArrayBase

    include("inputTypes.jl")
    include("utilsData.jl")
    include("getForcing.jl")
    include("getObservation.jl")
    
end # module SindbadData
