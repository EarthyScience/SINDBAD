module Sinbad
import DataStructures
using InteractiveUtils
using Reexport: @reexport
using CMAEvolutionStrategy:
    minimize,
    xbest
using CSV: CSV
using DocStringExtensions
#using FieldMetadata
using Flatten:
    flatten,
    metaflatten,
    fieldnameflatten,
    parentnameflatten
using JSON:
    parsefile
    #parse as jsparse,
    #read as jsread
using NCDatasets:
    Dataset
using Parameters
@reexport using PrettyPrinting:
    pprint
using Setfield:
    @set!
using TableOperations:
    select
using Tables:
    columntable,
    matrix
using TypedTables:
    Table
using StatsBase:
    mean,
    cor

include("Ecosystem/runEcosystem.jl")
include("optimization/optimization.jl")
include("tools/tools.jl")

include("models/models.jl")
@reexport using .Models

end
