module Sindbad
using Reexport: @reexport
using DataStructures: DataStructures
using DocStringExtensions
using Flatten: flatten, metaflatten, fieldnameflatten, parentnameflatten
using InteractiveUtils
using JLD2
using Parameters
@reexport using StaticArraysCore: StaticArray, SVector, MArray, SizedArray


include("utilsCore.jl")
include("sindbadVariableCatalog.jl")
include("Models/models.jl")
@reexport using .Models

end
