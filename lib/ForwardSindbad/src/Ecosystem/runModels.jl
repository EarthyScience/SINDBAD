export computeTEM
export definePrecomputeTEM
export foldlUnrolled
export precomputeTEM

"""
computeTEM(models, forcing, land, tem_helpers, ::Val{:false})
"""

"""
    computeTEM(models, forcing, land, tem_helpers, nothing::Val{:(true)})

DOCSTRING

# Arguments:
- `models`: DESCRIPTION
- `forcing`: DESCRIPTION
- `land`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function computeTEM(models, forcing, land, tem_helpers, ::Val{:true}) # debug the models
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
    computeTEM(models, forcing, land, tem_helpers, nothing::Val{:(false)})

DOCSTRING

# Arguments:
- `models`: DESCRIPTION
- `forcing`: DESCRIPTION
- `land`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
- `nothing`: DESCRIPTION
"""
function computeTEM(models, forcing, land, tem_helpers, ::Val{:false}) # do not debug the models 
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
- `forcing`: DESCRIPTION
- `land`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
"""
function computeTEM(models, forcing, land, tem_helpers) # do not debug the models 
    return foldlUnrolled(models; init=land) do _land, model
        _land = Models.compute(model, forcing, _land, tem_helpers)
    end
end

"""
    definePrecomputeTEM(models, forcing, land, tem_helpers)

DOCSTRING

# Arguments:
- `models`: DESCRIPTION
- `forcing`: DESCRIPTION
- `land`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
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
- `forcing`: DESCRIPTION
- `land`: DESCRIPTION
- `tem_helpers`: DESCRIPTION
"""
function precomputeTEM(models, forcing, land, tem_helpers)
    return foldlUnrolled(models; init=land) do _land, model
        _land = Models.precompute(model, forcing, _land, tem_helpers)
    end
end
