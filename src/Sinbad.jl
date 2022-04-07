module Sinbad
using InteractiveUtils
using Reexport: @reexport
@reexport begin
    using DocStringExtensions
    using FieldMetadata
    using Parameters
    using JSON:
        parse as jsparse,
        read as jsread
    using TypedTables:
        Table
    using Setfield:
        @set!
    using Statistics:
        mean
    using NCDatasets:
        Dataset
    using CMAEvolutionStrategy:
        minimize,
        xbest
    using Flatten:
        flatten,
        metaflatten,
        fieldnameflatten,
        parentnameflatten
    using Tables:
        columntable,
        matrix
    using TableOperations:
        select
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
include("Ecosystem/ecosystem.jl")
export getEcosystem
include("optimization/optimizeModel.jl")
export optimizeModel, getParameters, updateParameters
export getConstraintNames, getSimulationData, loss, getLoss
## reexport models/Models.jl
include("models/models.jl")
@reexport using .Models

end
