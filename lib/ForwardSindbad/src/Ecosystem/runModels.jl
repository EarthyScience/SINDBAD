export foldlUnrolled
export runCompute
export runDefinePrecompute
export runPrecompute

@generated function foldlUnrolled(f, x::Tuple{Vararg{Any,N}}; init) where {N}
    exes = Any[:(init = f(init, x[$i])) for i ∈ 1:N]
    return Expr(:block, exes...)
end

@generated function foldlUnrolled(f, x::Array{Sindbad.Models.LandEcosystem,N}; init) where {N}
    exes = Any[:(init = f(init, x[$i])) for i ∈ 1:N]
    return Expr(:block, exes...)
end

"""
runCompute(out, forcing, models, tem_helpers, ::Val{:false})
"""
function runCompute(out, forcing, models, tem_helpers, ::Val{:true}) # debug the models
    otype = typeof(out)
    return foldlUnrolled(models; init=out) do o, model
        @show typeof(model)
        @time o = Models.compute(model, forcing, o, tem_helpers)::otype
    end
end

"""
runCompute(out, forcing, models, tem_helpers)
"""
function runCompute(out, forcing, models, tem_helpers, ::Val{:false}) # do not debug the models 
    return foldlUnrolled(models; init=out) do o, model
        o = Models.compute(model, forcing, o, tem_helpers)
    end
end


"""
runCompute(out, forcing, models, tem_helpers)
"""
function runCompute(out, forcing, models, tem_helpers) # do not debug the models 
    return foldlUnrolled(models; init=out) do o, model
        o = Models.compute(model, forcing, o, tem_helpers)
    end
end

function runDefinePrecompute(out, forcing, models, tem_helpers)
    return foldlUnrolled(models; init=out) do o, model
        o = Models.define(model, forcing, o, tem_helpers)
        o = Models.precompute(model, forcing, o, tem_helpers)
    end
end

function runPrecompute(out, forcing, models, tem_helpers)
    return foldlUnrolled(models; init=out) do o, model
        o = Models.precompute(model, forcing, o, tem_helpers)
    end
end
