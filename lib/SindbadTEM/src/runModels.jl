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
    computeTEM(models, forcing, land, tem_helpers, ::DoDebugModel)

debug the compute function of SINDBAD models

# Arguments:
- `models`: a list of SINDBAD models to run
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::DoDebugModel`: a type dispatch to debug the compute functions of model
"""
function computeTEM(models, forcing, land, tem_helpers, ::DoDebugModel) # debug the models
    otype = typeof(land)
    return foldlUnrolled(models; init=land) do _land, model
        @show typeof(model)
        @time _land = Models.compute(model, forcing, _land, tem_helpers)#::otype
    end
end


"""
    computeTEM(models, forcing, land, tem_helpers, ::DoNotDebugModel)

run the compute function of SINDBAD models

# Arguments:
- `models`: a list of SINDBAD models to run
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
- `::DoNotDebugModel`: a type dispatch to not debug but run the compute functions of model
"""
function computeTEM(models, forcing, land, tem_helpers, ::DoNotDebugModel) # do not debug the models 
    return computeTEM(models, forcing, land, tem_helpers) 
end


"""
    computeTEM(models, forcing, land, tem_helpers)

run the compute function of SINDBAD models

# Arguments:
- `models`: a list of SINDBAD models to run
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
"""
function computeTEM(models::LongTuple, forcing, _land, tem_helpers) 
    return reduce_lt(models, init=_land) do model, _land
        println(nameof(typeof(model)))
        if nameof(typeof(model)) == :percolation_WBP
            push!(Main.catched_model_args,(model, forcing, _land, tem_helpers))
            error("Hahaha")
        end
        return @time Models.compute(model, forcing, _land, tem_helpers)
    end
end

"""
    definePrecomputeTEM(models, forcing, land, tem_helpers)

run the define and precompute functions of SINDBAD models to instantiate all fields of land

# Arguments:
- `models`: a list of SINDBAD models to run
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
    precomputeTEM(models, forcing, land, tem_helpers)

run the precompute function of SINDBAD models to instantiate all fields of land

# Arguments:
- `models`: a list of SINDBAD models to run
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
"""
function precomputeTEM(models::LongTuple, forcing, _land, tem_helpers)
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

"""
    computeTEM(models, forcing, land, tem_helpers)

run the compute function of SINDBAD models

# Arguments:
- `models`: a list of SINDBAD models to run
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
"""
function computeTEM(models::Tuple, forcing, land, tem_helpers) 
    return foldlUnrolled(models; init=land) do _land, model
        _land = Models.compute(model, forcing, _land, tem_helpers)
    end
end

"""
    precomputeTEM(models, forcing, land, tem_helpers)

run the precompute function of SINDBAD models to instantiate all fields of land

# Arguments:
- `models`: a list of SINDBAD models to run
- `forcing`: a forcing NT that contains the forcing time series set for ALL locations
- `land`: a core SINDBAD NT that contains all variables for a given time step that is overwritten at every timestep
- `tem_helpers`: helper NT with necessary objects for model run and type consistencies
"""
function precomputeTEM(models::Tuple, forcing, land, tem_helpers)
    return foldlUnrolled(models; init=land) do _land, model
        _land = Models.precompute(model, forcing, _land, tem_helpers)
    end
end

