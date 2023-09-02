export dictToNamedTuple
export dropFields
export getCombinedNamedTuple
export removeEmptyTupleFields
export setTupleField
export setTupleSubfield
export tcPrint

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