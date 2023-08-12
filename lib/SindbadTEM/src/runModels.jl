export computeTEM
export definePrecomputeTEM
export foldlUnrolled
export precomputeTEM

"""
computeTEM(models, forcing, land, tem_helpers, ::Val{:false})
"""

"""
    computeTEM(models, forcing, land, tem_helpers, ::DoDebugModel)

DOCSTRING

# Arguments:
- `models`: DESCRIPTION
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::DoDebugModel`: DESCRIPTION
"""
function computeTEM(models, forcing, land, tem_helpers, ::DoDebugModel) # debug the models
    otype = typeof(land)
    return foldlUnrolled(models; init=land) do _land, model
        @show typeof(model)
        @time _land = Models.compute(model, forcing, _land, tem_helpers)::otype
    end
end

"""
computeTEM(models, forcing, land, tem_helpers)
"""

"""
    computeTEM(models, forcing, land, tem_helpers, ::DoNotDebugModel)

DOCSTRING

# Arguments:
- `models`: DESCRIPTION
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::DoNotDebugModel`: DESCRIPTION
"""
function computeTEM(models, forcing, land, tem_helpers, ::DoNotDebugModel) # do not debug the models 
    return foldlUnrolled(models; init=land) do _land, model
        _land = Models.compute(model, forcing, _land, tem_helpers)
    end
end

"""
computeTEM(models, forcing, land, tem_helpers)
"""

"""
    computeTEM(models, forcing, land, tem_helpers)

DOCSTRING

# Arguments:
- `models`: DESCRIPTION
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
"""
function computeTEM(models, forcing, land, tem_helpers) 
    return foldlUnrolled(models; init=land) do _land, model
        _land = Models.compute(model, forcing, _land, tem_helpers)
    end
end

"""
    definePrecomputeTEM(models, forcing, land, tem_helpers)

DOCSTRING

# Arguments:
- `models`: DESCRIPTION
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
"""
function definePrecomputeTEM(models, forcing, land, tem_helpers)
    return foldlUnrolled(models; init=land) do _land, model
        _land = Models.define(model, forcing, _land, tem_helpers)
        _land = Models.precompute(model, forcing, _land, tem_helpers)
    end
end

"""
    foldlUnrolled(f, x::Tuple{Vararg{Any, N}}; init)

DOCSTRING

# Arguments:
- `f`: DESCRIPTION
- `x`: DESCRIPTION
- `init`: DESCRIPTION
"""
@generated function foldlUnrolled(f, x::Tuple{Vararg{Any,N}}; init) where {N}
    exes = Any[:(init = f(init, x[$i])) for i ∈ 1:N]
    return Expr(:block, exes...)
end

"""
    foldlUnrolled(f, x::Array{Sindbad.Models.LandEcosystem, N}; init)

DOCSTRING

# Arguments:
- `f`: DESCRIPTION
- `x`: DESCRIPTION
- `init`: DESCRIPTION
"""
@generated function foldlUnrolled(f, x::Array{Sindbad.Models.LandEcosystem,N}; init) where {N}
    exes = Any[:(init = f(init, x[$i])) for i ∈ 1:N]
    return Expr(:block, exes...)
end

"""
    precomputeTEM(models, forcing, land, tem_helpers)

DOCSTRING

# Arguments:
- `models`: DESCRIPTION
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
"""
function precomputeTEM(models, forcing, land, tem_helpers)
    return foldlUnrolled(models; init=land) do _land, model
        _land = Models.precompute(model, forcing, _land, tem_helpers)
    end
end
