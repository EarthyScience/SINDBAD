using LinearAlgebra
using Zarr, YAXArrays, NetCDF
#using Sindbad
using Dates

pathforcing = "/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_forcing.zarr"
pathobs = "/Net/Groups/BGI/work_1/scratch/lalonso/fluxnet_observations.zarr"

ds = YAXArrays.open_dataset(pathforcing)
staticVars = [:CLAY, :SAND, :SILT, :ORGM]
tempoVars = setdiff(collect(keys(ds.cubes)), staticVars)

cube_s = Cube(ds[staticVars])
cube_t = Cube(ds[tempoVars])

openobs = YAXArrays.open_dataset(pathobs)
cube_o = Cube(openobs)

# Note that this dataset also has additional meta data information per variable
ds.Rg.properties

# and the location for all sites 
ds.properties

# as well as a proper time axis [DimensionalData.jl works better here!]
ds.time