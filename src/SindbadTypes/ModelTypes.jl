
export ModelType
abstract type ModelType <: SindbadType end
purpose(::Type{ModelType}) = "Abstract type for model types in SINDBAD"

# ------------------------- land ecosystem type ------------------------------------------------------------
export LandEcosystem
abstract type LandEcosystem <: ModelType end

purpose(T::Type{LandEcosystem}) = nameof(T) == :LandEcosystem ? "Abstract type for all SINDBAD land ecosystem models/approaches" : "Purpose of a SINDBAD land ecosystem model/approach. Add `purpose(::Type{$(nameof(T))}) = \"the_purpose\"` in `$(nameof(T)).jl` file to define the specific purpose of the model/approach"

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

purpose(T::LandEcosystem) = purpose(typeof(T))

# ------------------------- model error handling type ------------------------------------------------------------
export DoCatchModelErrors
export DoNotCatchModelErrors

struct DoCatchModelErrors <: ModelType end
purpose(::Type{DoCatchModelErrors}) = "Enable error catching during model execution"

struct DoNotCatchModelErrors <: ModelType end
purpose(::Type{DoNotCatchModelErrors}) = "Disable error catching during model execution"