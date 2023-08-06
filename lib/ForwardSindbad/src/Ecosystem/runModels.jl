export foldlUnrolled
export runModelCompute
export runModelDefinePrecompute
export runModelPrecompute

@generated function foldlUnrolled(f, x::Tuple{Vararg{Any,N}}; init) where {N}
    exes = Any[:(init = f(init, x[$i])) for i ∈ 1:N]
    return Expr(:block, exes...)
end

@generated function foldlUnrolled(f, x::Array{Sindbad.Models.LandEcosystem,N}; init) where {N}
    exes = Any[:(init = f(init, x[$i])) for i ∈ 1:N]
    return Expr(:block, exes...)
end

"""
runModelCompute(land, forcing, models, tem_helpers, ::Val{:false})
"""
function runModelCompute(land, forcing, models, tem_helpers, ::Val{:true}) # debug the models
    otype = typeof(land)
    return foldlUnrolled(models; init=land) do _land, model
        @show typeof(model)
        @time _land = Models.compute(model, forcing, _land, tem_helpers)::otype
    end
end

"""
runModelCompute(land, forcing, models, tem_helpers)
"""
function runModelCompute(land, forcing, models, tem_helpers, ::Val{:false}) # do not debug the models 
    return foldlUnrolled(models; init=land) do _land, model
        _land = Models.compute(model, forcing, _land, tem_helpers)
    end
end


"""
runModelCompute(land, forcing, models, tem_helpers)
"""
function runModelCompute(land, forcing, models, tem_helpers) # do not debug the models 
    return foldlUnrolled(models; init=land) do _land, model
        _land = Models.compute(model, forcing, _land, tem_helpers)
    end
end

function runModelDefinePrecompute(land, forcing, models, tem_helpers)
    return foldlUnrolled(models; init=land) do _land, model
        _land = Models.define(model, forcing, _land, tem_helpers)
        _land = Models.precompute(model, forcing, _land, tem_helpers)
    end
end

function runModelPrecompute(land, forcing, models, tem_helpers)
    return foldlUnrolled(models; init=land) do _land, model
        _land = Models.precompute(model, forcing, _land, tem_helpers)
    end
end
