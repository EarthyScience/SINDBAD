module Models

# Import & export necessary modules/functions
using ..Sindbad
using FieldMetadata: @metadata
using Parameters: @with_kw
using StatsBase: mean
@metadata timescale "" String
@metadata describe "" String
@metadata bounds (-Inf, Inf) Tuple
@metadata units "" String
export describe, bounds, units
export DoCatchModelErrors
export DoNotCatchModelErrors
export @describe, @bounds, @units, @timescale
export @with_kw
export standard_sindbad_models
# define dispatch structs for catching model errors
struct DoCatchModelErrors end
struct DoNotCatchModelErrors end



## fallback functions for instantiate, precompute, compute and update. 
## These functions here make the corresponding functions in the model (approaches) optional
function compute(params::LandEcosystem, forcing, land, helpers)
    return land
end

function define(params::LandEcosystem, forcing, land, helpers)
    return land
end

function precompute(params::LandEcosystem, forcing, land, helpers)
    return land
end

function update(params::LandEcosystem, forcing, land, helpers)
    return land
end

# Import all models
all_folders = readdir(joinpath(@__DIR__, "."))
all_dir_models = filter(entry -> isdir(joinpath(@__DIR__, entry)), all_folders)

for model_name ∈ all_dir_models
    model_path = joinpath(model_name, model_name * ".jl")
    include(model_path)
end

# now having this ordered list is independent from the step including the models into this `module`.
include(joinpath(@__DIR__, "orderedModels.jl"))

end
