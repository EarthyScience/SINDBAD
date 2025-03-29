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
export getDocStringForApproach
export purpose
export purposes
export sindbad_models
export sindbad_compute_methods
export sindbad_define_methods
export sindbad_precompute_methods
export sindbad_update_methods
# define dispatch structs for catching model errors
struct DoCatchModelErrors end
struct DoNotCatchModelErrors end

missing_approach_purpose(x) = "$(x) is missing the definition of purpose. Add `purpose(::Type{$(nameof(x))})` = \"the_purpose\"` in `$(nameof(x)).jl` file to define the specific purpose"


function addDocStringForIO!(doc_string, io_list)
    if length(io_list) == 0
        doc_string *= " - None\n"
        return doc_string
    end
    foreach(io_list) do io_item
        var_info = getVariableInfo(Symbol(String(first(io_item))*"__"*String(last(io_item))), "time")
        v_d = var_info["description"]
        v_units = var_info["units"]
        v_units = isempty(v_units) ? "unitless" : "$(v_units)"
        if v_d == ""
            v_d = "No description available in Sindbad Variable catalog"
        end
        doc_string *= " - `$(first(io_item)).$(last(io_item))`: $(v_d) {$(v_units)}\n"
    end
    return doc_string
end

function getDocStringForApproach(appr)
    doc_string = "\n"

    doc_string *= "\t $(purpose(appr))\n\n"
    in_out_model = getInOutModel(appr, verbose=false)
    doc_string *= "# Parameters\n"
    params = in_out_model[:parameters]
    if length(params) == 0
        doc_string *= " - None\n"
    else
        for (i, param) in enumerate(params)
            ds="- `$(first(param))`: $(last(param))\n"
            doc_string *= ds
        end
    end
    # Parameters

    doc_string *= "---"

    # Methods
    d_methods = (:define, :precompute, :compute, :update)
    doc_string *= "\n\n# Methods:\n"
    for d_method in d_methods
        inputs = in_out_model[d_method][:input]
        outputs = in_out_model[d_method][:output]
        if length(inputs) == 0 && length(outputs) == 0
            doc_string *= "\n\n## $(d_method): not defined \n"
            continue
        else
            doc_string *= "\n\n## $(d_method):\n\n"
        end
        doc_string *= "*Inputs*\n"
        doc_string = addDocStringForIO!(doc_string, inputs)
        doc_string *= "\n*Outputs*\n"
        doc_string = addDocStringForIO!(doc_string, outputs)
    end
    doc_string *= "\n---\n"
    return doc_string
end



function getDocStringForModel(modl)
    doc_string = "\n"

    doc_string *= "\t $(purpose(modl))\n\n"

    doc_string *= "\n---\n"

    doc_string *= "# Approaches\n"
    foreach(subtypes(modl)) do subtype
        mod_name = string(nameof(subtype))
        mod_name = replace(mod_name, "_" => "\\_")
        p_s = purpose(subtype)
        p_s_w = p_s
        p_s_w = isnothing(p_s) ? missing_approach_purpose(subtype) : p_s
        doc_string *= " - $(mod_name): $(p_s_w)\n"
    end
    return doc_string
end

function includeAllApproaches(modl, dir)
    include.(filter(contains("$(nameof(modl))_"), readdir(dir; join=true)))
    # include.(fids)
    return
end

# include.(filter(contains(r"ambientCO2_"), readdir(@__DIR__; join=true)))

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


purpose(::Type{LandEcosystem}) = "A SINDBAD land ecosystem model/approach. Add `purpose(::Type{$(nameof(x))}) = \"the_purpose\"` in `$(nameof(x)).jl` file to define the specific purpose"

function purpose(T::Type{<:LandEcosystem}) 
    foreach(subtypes(T)) do subtype
        subsubtype = subtypes(subtype)
        if isempty(subsubtype)
            purpose(subtype)    
        else
            purpose.(subsubtype)
        end
    end
end

purpose(x::LandEcosystem) = purpose(typeof(x))

## List all models of SINDBAD in the order they are called. 
## Note that a new model is only executed if it is added to this list. 
## When adding a new model, create a new copy of this jl file to work with.
sindbad_models = (:wCycleBase,
    :rainSnow,
    :rainIntensity,
    :PET,
    :ambientCO2,
    :getPools,
    :soilTexture,
    :soilProperties,
    :soilWBase,
    :rootMaximumDepth,
    :rootWaterEfficiency,
    :PFT,
    :fAPAR,
    :EVI,
    :LAI,
    :NDVI,
    :NIRv,
    :NDWI,
    :treeFraction,
    :vegFraction,
    :snowFraction,
    :sublimation,
    :snowMelt,
    :interception,
    :runoffInfiltrationExcess,
    :saturatedFraction,
    :runoffSaturationExcess,
    :runoffInterflow,
    :runoffOverland,
    :runoffSurface,
    :runoffBase,
    :percolation,
    :evaporation,
    :drainage,
    :capillaryFlow,
    :groundWRecharge,
    :groundWSoilWInteraction,
    :groundWSurfaceWInteraction,
    :transpirationDemand,
    :vegAvailableWater,
    :transpirationSupply,
    :gppPotential,
    :gppDiffRadiation,
    :gppDirRadiation,
    :gppAirT,
    :gppVPD,
    :gppSoilW,
    :gppDemand,
    :WUE,
    :gpp,
    :transpiration,
    :rootWaterUptake,
    :cCycleBase,
    :cCycleDisturbance,
    :cTauSoilT,
    :cTauSoilW,
    :cTauLAI,
    :cTauSoilProperties,
    :cTauVegProperties,
    :cTau,
    :autoRespirationAirT,
    :cAllocationLAI,
    :cAllocationRadiation,
    :cAllocationSoilW,
    :cAllocationSoilT,
    :cAllocationNutrients,
    :cAllocation,
    :cAllocationTreeFraction,
    :autoRespiration,
    :cFlowSoilProperties,
    :cFlowVegProperties,
    :cFlow,
    :cCycleConsistency,
    :cCycle,
    :evapotranspiration,
    :runoff,
    :wCycle,
    :waterBalance,
    :deriveVariables)

## Import all models.
for model_name_symbol ∈ sindbad_models
    model_name = string(model_name_symbol)
    model_path = joinpath(model_name, model_name * ".jl")
    include(model_path)
end


function get_method_types(fn)
    # Get the method table for the function
    mt = methods(fn)
    # Extract the types of the first method
    method_types = map(m -> m.sig.parameters[2], mt)
    return method_types
end

sindbad_define_methods = get_method_types(define)
sindbad_compute_methods = get_method_types(compute)
sindbad_precompute_methods = get_method_types(precompute)
sindbad_update_methods = get_method_types(update)


end
