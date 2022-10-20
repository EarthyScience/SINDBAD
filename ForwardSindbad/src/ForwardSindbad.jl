module ForwardSindbad
#using Distributed
#addprocs(Sys.CPU_THREADS - 1)

using Sindbad
using InteractiveUtils
using YAXArrays, NetCDF, DiskArrayTools, Zarr
using YAXArrayBase
using RecursiveArrayTools
using AxisKeys, FillArrays
using ThreadPools
using StatsBase:
    mean,
    percentile,
    cor
using YAXArrays: savecube
using AxisKeys: KeyedArray, AxisKeys
using YAXArrayBase: getdata
using Flatten:
    flatten,
    metaflatten,
    fieldnameflatten,
    parentnameflatten
using TypedTables:
    Table
using JLD2: @save
using TimerOutputs
const tmr = TimerOutput()


include("tools/tools.jl")
include("Ecosystem/Ecosystem.jl")

end
