export setVariablesToStore
export updateVariablesToStore


"""
    getOrderedOutputList(varlist, var_o::Symbol)

return the corresponding variable from the full list

# Arguments:
- `varlist`: the full variable list 
- `var_o`: the variable to find
"""
function getOrderedOutputList(varlist, var_o::Symbol)
    for var ∈ varlist
        vname = Symbol(split(string(var), '.')[end])
        if vname === var_o
            return var
        end
    end
end


"""
    getVariableGroups(var_list::AbstractArray)

get named tuple for variables groups from list of variables. Assumes that the entries in the list follow subfield.variablename of model output (land
"""
function getVariableGroups(var_list::AbstractArray)
    var_dict = Dict()
    for var ∈ var_list
        var_l = String(var)
        vf = split(var_l, ".")[1]
        vvar = split(var_l, ".")[2]
        if vf ∉ keys(var_dict)
            var_dict[vf] = []
            push!(var_dict[vf], vvar)
        else
            push!(var_dict[vf], vvar)
        end
    end
    varNT = (;)
    for (k, v) ∈ var_dict
        varNT = setTupleField(varNT, (Symbol(k), tuple(Symbol.(v)...)))
    end
    return varNT
end


"""
    getVariablePair(out_var)

return a vector of pairs with field and subfield of land from the list of variables (output_vars) in field.subfield convention
"""
function getVariablePair(out_var::String)
    sep = "."
    if occursin(",", out_var)
        sep = ","
    end
    return Tuple(Symbol.(split(string(out_var), sep)))
end


"""
    getVariablePair(out_var)

return a vector of pairs with field and subfield of land from the list of variables (output_vars) in field.subfield convention
"""
function getVariablePair(out_var::Symbol)
    getVariablePair(string(out_var))
end

"""
    setVariablesToStore(info::NamedTuple)

sets info.tem.variables as the union of variables to write and store from model_run[.json]. These are the variables for which the time series will be filtered and saved
"""
function setVariablesToStore(info::NamedTuple)
    output_vars = collect(propertynames(info.experiment.model_output.variables))
    out_vars_pairs = Tuple(getVariablePair.(output_vars))
    info = (; info..., tem=(; info.tem..., variables=out_vars_pairs))
    return info
end



"""
    updateVariablesToStore(info::NamedTuple)

sets info.tem.variables as the union of variables to write and store from model_run[.json]. These are the variables for which the time series will be filtered and saved
"""
function updateVariablesToStore(info::NamedTuple)
    output_vars = info.experiment.model_output.variables
    if info.experiment.flags.run_optimization
        output_vars = map(info.optim.variables.obs) do vo
            vn = getfield(info.optim.variables.optim, vo)
            Symbol(string(vn[1]) * "." * string(vn[2]))
        end
    elseif info.experiment.flags.calc_cost
        output_vars = union(String.(keys(info.experiment.model_output.variables)),
                info.optim.variables.model)
    end
    out_vars_pairs = Tuple(getVariablePair.(output_vars))
    info = (; info..., tem=(; info.tem..., variables=out_vars_pairs))
    return info
end
