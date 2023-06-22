export runModels!, foldl_unrolled

@generated function foldl_unrolled(f, x::Tuple{Vararg{Any,N}}; init) where {N}
    exes = Any[:(init = f(init, x[$i])) for i ∈ 1:N]
    return Expr(:block, exes...)
end

"""
runModels(forcing, models, out)
"""
function runModels!(out, forcing, models, tem_helpers, ::Val{:debugit})
    otype = typeof(out)
    return foldl_unrolled(models; init=out) do o, model
        @show typeof(model)
        @time o = Models.compute(model, forcing, o, tem_helpers)::otype
    end
end

"""
runModels(forcing, models, out)
"""
function runModels!(out, forcing, models, tem_helpers)
    return foldl_unrolled(models; init=out) do o, model
        return o = Models.compute(model, forcing, o, tem_helpers)
    end
end
