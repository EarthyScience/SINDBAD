
export updateModelParameters
export getParameterIndices


function getModelParameterIndices(model, tbl_params, r)
    modelName = nameof(typeof(model))
    empty!(r)
    for var in propertynames(model)
        pindex = findfirst(row -> row.name == var && row.model_approach == modelName, tbl_params)
        if !isnothing(pindex)
            push!(r, var => pindex)
        end
    end
    NamedTuple((modelName => NamedTuple(r),))
end

function getParameterIndices(selected_models::LongTuple, tbl_params)
    selected_models_tuple = getTupleFromLongTable(selected_models)
    return getParameterIndices(selected_models_tuple, tbl_params)
end

function getParameterIndices(selected_models::Tuple, tbl_params)
    r = (;)
    tempvec = Pair{Symbol,Int}[]
    for m in selected_models
        r = (; r..., getModelParameterIndices(m, tbl_params, tempvec)...)
    end
    r
end


"""
    updateModelParameters(tbl_params, selected_models::Tuple, param_vector)

update models/parameters without mutating the table of parameters

# Arguments:
- `tbl_params`: a table of SINDBAD model parameters selected for the optimization
- `selected_models`: a tuple of all models selected in the given model structure
- `param_vector`: a vector of parameter values to update the models
"""
function updateModelParameters(tbl_params::Table, selected_models_in::LongTuple, param_vector::AbstractArray)
    selected_models = getTupleFromLongTable(selected_models_in)
    return updateModelParameters(tbl_params, selected_models, param_vector)
end


"""
    updateModelParameters(tbl_params, selected_models::Tuple, param_vector)

update models/parameters without mutating the table of parameters

# Arguments:
- `tbl_params`: a table of SINDBAD model parameters selected for the optimization
- `selected_models`: a tuple of all models selected in the given model structure
- `param_vector`: a vector of parameter values to update the models
"""
function updateModelParameters(tbl_params::Table, selected_models::Tuple, param_vector::AbstractArray)
    updatedModels = Models.LandEcosystem[]
    namesApproaches = nameof.(typeof.(selected_models)) # a better way to do this?
    for (idx, modelName) ∈ enumerate(namesApproaches)
        approachx = selected_models[idx]
        model_obj = approachx
        newapproachx = if modelName in tbl_params.model_approach
            vars = propertynames(approachx)
            newvals = Pair[]
            for var ∈ vars
                pindex = findall(row -> row.name == var && row.model_approach == modelName,
                    tbl_params)
                pval = getproperty(approachx, var)
                if !isempty(pindex)
                    pval = param_vector[pindex[1]]
                end
                push!(newvals, var => pval)
            end
            typeof(approachx)(; newvals...)
        else
            approachx
        end
        push!(updatedModels, newapproachx)
    end
    return (updatedModels...,)
end


function updateModelParameters(param_to_index::NamedTuple, selected_models, param_vector::AbstractArray)
    map(selected_models) do model
          modelmap = param_to_index[nameof(typeof(model))]
          varsreplace = map(i->param_vector[i],modelmap)
          ConstructionBase.setproperties(model,varsreplace)
    end
end


@generated function updateModelParameters(selected_models, param_vector::AbstractArray, ::Val{p_vals}) where p_vals
    gen_output = quote end
    p_index = 1
    foreach(p_vals) do p
        param = Symbol(split(string(first(p)), "____")[end])
        mod_index = last(p)
        push!(gen_output.args,
            Expr(:(=),
                :selected_models,
                Expr(:macrocall,
                    Symbol("@set"),
                    :(),
                    Expr(:(=), Expr(:., Expr(:ref, :selected_models, mod_index), QuoteNode(param)), Expr(:ref, :param_vector, p_index))))) #= none:1 =#
                    p_index += 1
    end
    return gen_output
end