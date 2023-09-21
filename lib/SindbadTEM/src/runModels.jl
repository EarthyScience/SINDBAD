export computeTEM
export definePrecomputeTEM
export foldlUnrolled
export precomputeTEM

"""
    computeTEM(models, forcing, land, model_helpers, ::DoDebugModel)

debug the compute function of SINDBAD models

# Arguments:
- `models`: a list of SINDBAD models to run
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `model_helpers`: helper NT with necessary objects for model run and type consistencies
- `::DoDebugModel`: a type dispatch to debug the compute functions of model
"""
function computeTEM(models, forcing, land, model_helpers, ::DoDebugModel) # debug the models
    otype = typeof(land)
    return foldlUnrolled(models; init=land) do _land, model
        println("compute: $(typeof(model))")
        @time _land = Models.compute(model, forcing, _land, model_helpers)#::otype
    end
end


"""
    computeTEM(models, forcing, land, model_helpers, ::DoNotDebugModel)

run the compute function of SINDBAD models

# Arguments:
- `models`: a list of SINDBAD models to run
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `model_helpers`: helper NT with necessary objects for model run and type consistencies
- `::DoNotDebugModel`: a type dispatch to not debug but run the compute functions of model
"""
function computeTEM(models, forcing, land, model_helpers, ::DoNotDebugModel) # do not debug the models 
    return computeTEM(models, forcing, land, model_helpers) 
end


"""
    computeTEM(models, forcing, land, model_helpers)

run the compute function of SINDBAD models

# Arguments:
- `models`: a list of SINDBAD models to run
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `model_helpers`: helper NT with necessary objects for model run and type consistencies
"""
function computeTEM(models, forcing, land, model_helpers) 
    return foldlUnrolled(models; init=land) do _land, model
        _land = Models.compute(model, forcing, _land, model_helpers)
    end
end

"""
    definePrecomputeTEM(models, forcing, land, model_helpers)

run the define and precompute functions of SINDBAD models to instantiate all fields of land

# Arguments:
- `models`: a list of SINDBAD models to run
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `model_helpers`: helper NT with necessary objects for model run and type consistencies
"""
function definePrecomputeTEM(models, forcing, land, model_helpers)
    return foldlUnrolled(models; init=land) do _land, model
        _land = Models.define(model, forcing, _land, model_helpers)
        _land = Models.precompute(model, forcing, _land, model_helpers)
    end
end

"""
    foldlUnrolled(f, x::Tuple{Vararg{Any, N}}; init)

generate the expression to run the function for each element of a given Tuple to avoid complexity of for loops for compiler

# Arguments:
- `f`: a function call
- `x`: the iterative to loop through
- `init`: initial variable to overwrite
"""
@generated function foldlUnrolled(f, x::Tuple{Vararg{Any,N}}; init) where {N}
    exes = Any[:(init = f(init, x[$i])) for i ∈ 1:N]
    return Expr(:block, exes...)
end


"""
    precomputeTEM(models, forcing, land, model_helpers, ::DoDebugModel)

debug the precompute function of SINDBAD models

# Arguments:
- `models`: a list of SINDBAD models to run
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `model_helpers`: helper NT with necessary objects for model run and type consistencies
- `::DoDebugModel`: a type dispatch to debug the compute functions of model
"""
function precomputeTEM(models, forcing, land, model_helpers, ::DoDebugModel) # debug the models
    otype = typeof(land)
    return foldlUnrolled(models; init=land) do _land, model
        println("precompute: $(typeof(model))")
        @time _land = Models.precompute(model, forcing, _land, model_helpers)#::otype
    end
end


"""
    precomputeTEM(models, forcing, land, model_helpers, ::DoNotDebugModel)

run the precompute function of SINDBAD models

# Arguments:
- `models`: a list of SINDBAD models to run
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `model_helpers`: helper NT with necessary objects for model run and type consistencies
- `::DoNotDebugModel`: a type dispatch to not debug but run the compute functions of model
"""
function precomputeTEM(models, forcing, land, model_helpers, ::DoNotDebugModel) # do not debug the models 
    return precomputeTEM(models, forcing, land, model_helpers) 
end


"""
    precomputeTEM(models, forcing, land, model_helpers)

run the precompute function of SINDBAD models to instantiate all fields of land

# Arguments:
- `models`: a list of SINDBAD models to run
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `model_helpers`: helper NT with necessary objects for model run and type consistencies
"""
function precomputeTEM(models, forcing, land, model_helpers)
    return foldlUnrolled(models; init=land) do _land, model
        _land = Models.precompute(model, forcing, _land, model_helpers)
    end
end
