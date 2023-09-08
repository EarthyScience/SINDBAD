export computeTEM
export computeTEMOne
export definePrecomputeTEM
export foldlUnrolled
export precomputeTEM
export LongTuple

struct LongTuple{T <: Tuple}
    data::T
    function LongTuple(arg::T) where {T<: Tuple}
        return new{T}(arg)
    end
    function LongTuple(args...)
        n = 6
        s = length(args)
        nt = s ÷ n
        r = mod(s,n)
        nt = r == 0 ? nt : nt + 1
        idx = 1
        tup = ntuple(nt) do i
            n = r != 0 && i==nt ? r : n
            t = ntuple(x -> args[x+idx-1], n)
            idx += n
            return t
        end
        return new{typeof(tup)}(tup)
    end
end

Base.map(f, arg::LongTuple) = LongTuple(map(tup-> map(f, tup), arg.data))

@inline Base.foreach(f, arg::LongTuple) = foreach(tup-> foreach(f, tup), arg.data)

#Base.foreach(f, arg::LongTuple, args...) = foreach(tup-> foreach((x)-> f(x, args...), tup), arg.data)

@generated function reduce_lt(f, x::LongTuple{<: Tuple{Vararg{Any,N}}}; init) where {N}
    exes = []
    for i in 1:N
        N2 = i==N ? 5 : 6
        for j in 1:N2
            push!(exes, :(init = f(x.data[$i][$j], init)))
        end
    end
    return Expr(:block, exes...)
end

"""
computeTEM(models, forcing, land, tem_helpers, ::Val{:false})
"""

"""
    computeTEM(models, forcing, land, tem_helpers, ::DoDebugModel)



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
        #@show typeof(model)
        _land = Models.compute(model, forcing, _land, tem_helpers)::otype
    end
end

"""
computeTEM(models, forcing, land, tem_helpers)
"""

"""
    computeTEM(models, forcing, land, tem_helpers, ::DoNotDebugModel)



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
    computeTEMOne(models, forcing, land, tem_helpers)



# Arguments:
- `models`: DESCRIPTION
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
"""
function computeTEMOne(models, forcing, land, tem_helpers) 
    return foldlUnrolled(models; init=land) do _land, model
        _land = Models.compute(model, forcing, _land, tem_helpers)
    end
end


"""
    computeTEM(models, forcing, land, tem_helpers)



# Arguments:
- `models`: DESCRIPTION
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
"""
function computeTEM(models, forcing, _land, tem_helpers) 
    return reduce_lt(models, init=_land) do model, _land
        return Models.compute(model, forcing, _land, tem_helpers)
    end
end

"""
    definePrecomputeTEM(models, forcing, land, tem_helpers)



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



# Arguments:
- `f`: DESCRIPTION
- `x`: DESCRIPTION
- `init`: DESCRIPTION
"""
# @generated function foldlUnrolled(f, x::Array{Sindbad.Models.LandEcosystem, N}; init) where {N}
#     exes = Any[:(init = f(init, x[$i])) for i ∈ 1:65]
#     return Expr(:block, exes...)
# end


"""
    precomputeTEM(models, forcing, land, tem_helpers)



# Arguments:
- `models`: DESCRIPTION
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
"""
function precomputeTEM(models, forcing, _land, tem_helpers)
    #_land = Ref(land)
    return reduce_lt(models, init=_land) do model, _land
        return Models.precompute(model, forcing, _land, tem_helpers)
    end
end


# function RUN!!(models, land_init)
#     land = Ref(land_init)
#     foreach(models) do model
#         land[] = compute(model, land[])
#     end
#     return land[]
# end