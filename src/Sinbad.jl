module Sinbad
using InteractiveUtils
using Reexport: @reexport
@reexport begin
    using CMAEvolutionStrategy:
        minimize,
        xbest
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
end

export setTupleField, setTupleSubfield
include("tools/utils.jl")
include("tools/getConfiguration.jl")
export getConfiguration
include("tools/getForcing.jl")
export getForcing
include("tools/getObservation.jl")
export getObservation
include("tools/setupModel.jl")
export setupModel!
include("Ecosystem/runEcosystem.jl")
export runEcosystem, runSpinup, runForward
include("optimization/optimizeModel.jl")
export optimizeModel, getParameters, updateParameters
export getConstraintNames, getSimulationData, loss, getLoss
## reexport models/Models.jl
include("models/models.jl")
@reexport using .Models

end
