module Sindbad
using Reexport: @reexport
@reexport using CodeTracking
@reexport using DataStructures: DataStructures
using DocStringExtensions
@reexport using Flatten: flatten, metaflatten, fieldnameflatten, parentnameflatten
@reexport using InteractiveUtils
using Parameters
@reexport using Reexport
@reexport using StaticArraysCore: StaticArray, SVector, MArray, SizedArray

## Define SINDBAD supertype
export LandEcosystem
abstract type LandEcosystem end

include("utilsCore.jl")
include("sindbadVariableCatalog.jl")
include("modelTools.jl")
include("Models/models.jl")
include("generateCode.jl")
@reexport using .Models
end
