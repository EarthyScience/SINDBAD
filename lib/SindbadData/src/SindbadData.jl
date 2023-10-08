module SindbadData

    using SindbadUtils
    using AxisKeys: KeyedArray, AxisKeys
    using FillArrays
    using DimensionalData
    using DiskArrayTools
    using NetCDF
    using NCDatasets
    using YAXArrays
    using YAXArrayBase
    using Zarr

    include("inputTypes.jl")
    include("utilsData.jl")
    include("getForcing.jl")
    include("getObservation.jl")
    
end # module SindbadData
