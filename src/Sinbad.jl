module Sinbad
import DataStructures
using InteractiveUtils
using Reexport: @reexport
@reexport begin
    using CMAEvolutionStrategy:
        minimize,
        xbest
    using DataFrames:
        DataFrame
    using DocStringExtensions
    using FieldMetadata
    using Flatten:
        flatten,
        metaflatten,
        fieldnameflatten,
        parentnameflatten
    using JSON:
        parse as jsparse,
        read as jsread
    using NCDatasets:
        Dataset
    using Parameters
    using PrettyPrinting
    using Setfield:
        @set!
    using Statistics:
        mean
    using TableOperations:
        select
    using Tables:
        columntable,
        matrix
    using TypedTables:
        Table
    using StatsBase:
        mean
end

include("Ecosystem/runEcosystem.jl")
include("optimization/optimization.jl")
include("tools/tools.jl")

include("models/models.jl")
@reexport using .Models

end
