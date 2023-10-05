export dictToNamedTuple
export dropFields
export foldlLongTuple
export foldlUnrolled
export LongTuple
export getCombinedNamedTuple
export getTupleFromLongTable
export makeLongTuple
export makeNamedTuple
export removeEmptyTupleFields
export setTupleField
export setTupleSubfield
export tcPrint

struct LongTuple{NSPLIT,T <: Tuple}
    data::T
    n::Val{NSPLIT}
    function LongTuple{n}(arg::T) where {n,T<: Tuple}
        return new{n,T}(arg,Val{n}())
    end
    function LongTuple{n}(args...) where n
        s = length(args)
        nt = s ÷ n
        r = mod(s,n) # 5 for our current use case
        nt = r == 0 ? nt : nt + 1
        idx = 1
        tup = ntuple(nt) do i
            nn = r != 0 && i==nt ? r : n
            t = ntuple(x -> args[x+idx-1], nn)
            idx += nn
            return t
        end
        return new{n,typeof(tup)}(tup)
    end
end

Base.map(f, arg::LongTuple{N}) where N = LongTuple{N}(map(tup-> map(f, tup), arg.data))

@inline Base.foreach(f, arg::LongTuple) = foreach(tup-> foreach(f, tup), arg.data)


"""
    collectColorForTypes(d; c_olor = true)

utility function to collect colors for all types from nested namedtuples
"""
function collectColorForTypes(d; c_olor=true)
    all_types = []
    all_types = getTypes!(d, all_types)
    c_types = Dict{DataType,Int}()
    for t ∈ all_types
        if c_olor == true
            c = rand(0:255)
        else
            c = 0
        end
        c_types[t] = c
    end
    return c_types
end


"""
    dictToNamedTuple(d::AbstractDict)

covert nested dictionary to NamedTuple
"""
function dictToNamedTuple(d::AbstractDict)
    for k ∈ keys(d)
        if d[k] isa Array{Any,1}
            d[k] = [v for v ∈ d[k]]
        elseif d[k] isa DataStructures.OrderedDict
            d[k] = dictToNamedTuple(d[k])
        end
    end
    dTuple = NamedTuple{Tuple(Symbol.(keys(d)))}(values(d))
    return dTuple
end


@generated function foldlLongTuple(f, x::LongTuple{NSPL,T}; init) where {T,NSPL}
    exes = []
    N = length(T.parameters)
    lastlength = length(last(T.parameters).parameters)
    for i in 1:N
        N2 = i==N ? lastlength : NSPL
        for j in 1:N2
            push!(exes, :(init = f(x.data[$i][$j], init)))
        end
    end
    return Expr(:block, exes...)
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
    dropFields(namedtuple::NamedTuple, names::Tuple{Vararg{Symbol}})

removes the list of fields from a given named tuple

# Arguments:
- `namedtuple`: a namedtuple to remove the fields from
- `names`: a tuple of names to be removed
"""
function dropFields(namedtuple::NamedTuple, names::Tuple{Vararg{Symbol}}) 
    keepnames = Base.diff_names(Base._nt_names(namedtuple), names)
   return NamedTuple{keepnames}(namedtuple)
end

"""
    getCombinedNamedTuple(base_nt::NamedTuple, priority_nt::NamedTuple)

combines the property values of the base NT with the properties set for the particular field from priority NT

"""
function getCombinedNamedTuple(base_nt::NamedTuple, priority_nt::NamedTuple)
    combined_nt = (;)
    base_fields = propertynames(base_nt)
    var_fields = propertynames(priority_nt)
    all_fields = Tuple(unique([base_fields..., var_fields...]))
    for var_field ∈ all_fields
        field_value = nothing
        if hasproperty(base_nt, var_field)
            field_value = getfield(base_nt, var_field)
        else
            field_value = getfield(priority_nt, var_field)
        end
        if hasproperty(priority_nt, var_field)
            var_prop = getfield(priority_nt, var_field)
            if !isnothing(var_prop) && length(var_prop) > 0
                field_value = getfield(priority_nt, var_field)
            end
        end
        combined_nt = setTupleField(combined_nt,
            (var_field, field_value))
    end
    return combined_nt
end

function getTupleFromLongTable(long_tuple)
    emp_vec = []
    foreach(long_tuple) do lt
        push!(emp_vec, lt)
    end
    return Tuple(emp_vec)
end

"""
    getTypes!(d, all_types)

utility function to collect all types from nested namedtuples
"""
function getTypes!(d, all_types)
    for k ∈ keys(d)
        if d[k] isa NamedTuple
            push!(all_types, typeof(d[k]))
            getTypes!(d[k], all_types)
        else
            push!(all_types, typeof(d[k]))
        end
    end
    return unique(all_types)
end



"""
    makeLongTuple(normal_tuple; longtuple_size=5)

# Arguments:
- `normal_tuple`: a normal tuple
- `longtuple_size`: size to break down the tuple into
"""
function makeLongTuple(normal_tuple::Tuple, longtuple_size=5)
    longtuple_size = min(length(normal_tuple), longtuple_size)
    LongTuple{longtuple_size}(normal_tuple...)
end


"""
    makeLongTuple(normal_tuple; longtuple_size=5)

# Arguments:
- `normal_tuple`: a normal tuple
- `longtuple_size`: size to break down the tuple into
"""
function makeLongTuple(long_tuple::LongTuple, longtuple_size=5)
    long_tuple
end

"""
    makeNamedTuple(input_data, input_names)

# Arguments:
- `input_data`: a vector of data
- `input_names`: a vector/tuple of names
"""
function makeNamedTuple(input_data, input_names)
    return (; Pair.(input_names, input_data)...)
end

"""
    removeEmptyTupleFields(tpl::NamedTuple)


"""
function removeEmptyTupleFields(tpl::NamedTuple)
    indx = findall(x -> x != NamedTuple(), values(tpl))
    nkeys, nvals = tuple(collect(keys(tpl))[indx]...), values(tpl)[indx]
    return NamedTuple{nkeys}(nvals)
end


"""
    setTupleSubfield(out, fieldname, vals)



# Arguments:
- `out`: DESCRIPTION
- `fieldname`: DESCRIPTION
- `vals`: DESCRIPTION
"""
function setTupleSubfield(out, fieldname, vals)
    return (; out..., fieldname => (; getfield(out, fieldname)..., first(vals) => last(vals)))
end

setTupleField(out, vals) = (; out..., first(vals) => last(vals))


"""
    tcPrint(d, df = 1; c_olor = true, t_ype = true, istop = true)

- a helper function to navigate the input named tuple and annotate types.
- a random set of colors is chosen per type of the data/field
- a mixed colored output within a feild usually warrants caution on type mismatches

# Arguments:
- `d`: DESCRIPTION
- `df`: DESCRIPTION
- `c_olor`: DESCRIPTION
- `t_ype`: DESCRIPTION
- `istop`: DESCRIPTION
"""
function tcPrint(d, df=1; c_olor=true, t_ype=true, istop=true)
    colors_types = collectColorForTypes(d; c_olor=c_olor)
    lc = nothing
    tt = "\t"
    for k ∈ sort(keys(d))
        # lc = colors_types[typeof(d[k])]
        if d[k] isa NamedTuple
            tt = ""
            if t_ype == true
                tp = " = (; "
                # lc = colors_types[typeof(d[k])]
            else
                tp = ""
            end
            if df != 1
                tt = repeat("\t", df)
            end
            print(Crayon(; foreground=colors_types[typeof(d[k])]), "$(tt) $(k)$(tp)\n")
            tcPrint(d[k], df; c_olor=c_olor, t_ype=t_ype, istop=false)
        else
            tt = repeat("\t", df)
            if t_ype == true
                tp = "::$(typeof(d[k]))"
                if tp == "::NT"
                    tp = "::Tuple"
                end
            else
                tt = repeat("\t", df)
                tp = ""
            end
            if typeof(d[k]) <: Float32
                print(Crayon(; foreground=colors_types[typeof(d[k])]),
                    "$(tt) $(k) = $(d[k])f0$(tp),\n")
            elseif typeof(d[k]) <: SVector
                print(Crayon(; foreground=colors_types[typeof(d[k])]),
                    "$(tt) $(k) = SVector{$(length(d[k]))}($(d[k]))$(tp),\n")
            elseif typeof(d[k]) <: Matrix
                print(Crayon(; foreground=colors_types[typeof(d[k])]), "$(tt) $(k) = [\n")
                tt_row = repeat(tt[1], length(tt) + 1)
                for _d ∈ eachrow(d[k])
                    d_str = nothing
                    if eltype(_d) == Float32
                        d_str = join(_d, "f0 ") * "f0"
                    else
                        d_str = join(_d, " ")
                    end
                    print(Crayon(; foreground=colors_types[typeof(d[k])]),
                        "$(tt_row) $(d_str);\n")
                end
                print(Crayon(; foreground=colors_types[typeof(d[k])]), "$(tt_row) ]$(tp),\n")
            else
                print(Crayon(; foreground=colors_types[typeof(d[k])]),
                    "$(tt) $(k) = $(d[k])$(tp),\n")
            end
            lc = colors_types[typeof(d[k])]
        end
        # if k == last(keys(d))
        #     print(Crayon(foreground = colors_types[typeof(d[k])]), "$(tt))::NamedTuple,\n")
        # end
        df = 1
    end
    if t_ype == true
        tt = tt * " "
        print(Crayon(; foreground=lc), "$(tt))::NamedTuple,\n")
    else
        print(Crayon(; foreground=lc), "$(tt)),\n")
    end
end