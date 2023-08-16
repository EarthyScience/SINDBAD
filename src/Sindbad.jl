module Sindbad
using Reexport: @reexport
@reexport using DataStructures: DataStructures
using DocStringExtensions
@reexport using Flatten: flatten, metaflatten, fieldnameflatten, parentnameflatten
@reexport using InteractiveUtils
using Parameters
@reexport using Reexport
@reexport using StaticArraysCore: StaticArray, SVector, MArray, SizedArray

include("utilsCore.jl")
include("sindbadVariableCatalog.jl")
include("Models/models.jl")
@reexport using .Models
end
