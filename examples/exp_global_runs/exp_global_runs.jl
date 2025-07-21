ENV["JULIA_NUM_PRECOMPILE_TASKS"] = "1"
using SindbadTEM
using SindbadML
using SindbadData
using SindbadData.YAXArrays
using SindbadData.Zarr
using SindbadData.DimensionalData
using SindbadML.JLD2
using TypedTables
using Flux

## paths