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

# ? load trained neural network
path_model = joinpath("/Net/Groups/BGI/work_5/scratch/lalonso/checkpoint_epoch_208.jld2")

trainedNN, lower_bound, upper_bound, ps_names, metadata_global = 
    loadTrainedNN(path_model)

# ? load global PFT dataset
ds = open_dataset("/Net/Groups/BGI/work_5/scratch/lalonso/covariates_global_0d25.zarr")
cube_PFTs = readcubedata(ds["PFT_mask"])
cube_KG = readcubedata(ds["KG_mask"])

ds_skip = open_dataset("/Net/Groups/BGI/work_5/scratch/lalonso/covariates_global_0d25.zarr";
    skip_keys=(:PFT_mask, :KG_mask),)

ds_skip_cube = Cube(ds_skip)
c_keys = string.(ds_skip.cubes.keys) |> sort # ! this is a flaw, order should be consistent with training, hence it should be an output from there as well.

ds_cubes_in = ds_skip_cube[Variables = At(c_keys)]
ds_cubes_in = readcubedata(ds_cubes_in)

# ? compute and save new parameters
ps_path = "/Net/Groups/BGI/work_5/scratch/lalonso/parameters_ALL_new_0d25.zarr"

out_params = mapParamsAll([cube_PFTs, cube_KG, ds_cubes_in], trainedNN, lower_bound, upper_bound, ps_names, ps_path;
    metadata_global= metadata_global
    )

# TODO: run only with PFTs as covariates! and neural network trained with PFTs only
# ? load trained neural network
path_model_pft = joinpath("/Net/Groups/BGI/work_5/scratch/lalonso/checkpoint_epoch_208.jld2") #! update path!
trainedNN, lower_bound, upper_bound, ps_names, metadata_global = 
    loadTrainedNN(path_model_pft)

## ? load global PFT dataset
ds = open_dataset("/Net/Groups/BGI/work_5/scratch/lalonso/CovariatesGlobal_025.zarr")
cube_PFTs = readcubedata(ds["PFT_mask"])
cube_PFTs = Float32.(cube_PFTs)
# ? match spatial grid dimensions
cube_PFTs = YAXArray((longitude(-179.875:0.25:179.875), latitude(89.875:-0.25:-89.875)),
    cube_PFTs.data, cube_PFTs.properties)

    # ? compute and save new parameters
ps_path = "/Net/Groups/BGI/work_5/scratch/lalonso/parameters_PFT_new_0d25.zarr"

out_params = mapParamsPFT(cube_PFTs, trainedNN, lower_bound, upper_bound, ps_names, ps_path;
    metadata_global= metadata_global)