
export updateModelParameters
export updateModelParametersType
export param_indices

"""
    updateModelParameters(tbl_params::Table, selected_models::Tuple)


"""
function updateModelParameters(tbl_params::Table, selected_models::Tuple)
    function filtervar(var, modelName, tbl_params, approachx)
        subtbl = filter(row -> row.name == var && row.model_approach == modelName, tbl_params)
        if isempty(subtbl)
            return getproperty(approachx, var)
        else
            return subtbl.optim[1]
        end
    end
    updatedModels = Models.LandEcosystem[]
    namesApproaches = nameof.(typeof.(selected_models)) # a better way to do this?
    for (idx, modelName) ∈ enumerate(namesApproaches)
        approachx = selected_models[idx]
        newapproachx = if modelName in tbl_params.model_approach
            vars = propertynames(approachx)
            newvals = Pair[]
            for var ∈ vars
                inOptim = filtervar(var, modelName, tbl_params, approachx)
                push!(newvals, var => inOptim)
            end
            typeof(approachx)(; newvals...)
        else
            approachx
        end
        push!(updatedModels, newapproachx)
    end
    return (updatedModels...,)
end


"""
    updateModelParameters(tbl_params, selected_models::Tuple, param_vector)

update models/parameters without mutating the table of parameters

# Arguments:
- `tbl_params`: a table of SINDBAD model parameters selected for the optimization
- `selected_models`: a tuple of all models selected in the given model structure
- `param_vector`: DESCRIPTION
"""
function updateModelParameters(tbl_params::Table, selected_models::Tuple, param_vector)
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

"""
    updateModelParametersType(tbl_params, selected_models::Tuple, param_vector)

get the new instances of the model with same parameter types as mentioned in param_vector

# Arguments:
- `tbl_params`: a table of SINDBAD model parameters selected for the optimization
- `selected_models`: a tuple of all models selected in the given model structure
- `param_vector`: DESCRIPTION
"""
function updateModelParametersType(tbl_params, selected_models::Tuple, param_vector)
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
                    model_obj = tbl_params[pindex[1]].approach_func
                    pval = param_vector[pindex[1]]
                end
                push!(newvals, var => pval)
            end
            model_obj(; newvals...)
        else
            approachx
        end
        push!(updatedModels, newapproachx)
    end
    return (updatedModels...,)
end


@generated function updateModelParameters(selected_models, param_vector, ::Val{p_vals}) where p_vals
    output = quote end
    p_index = 1
    foreach(p_vals) do p
        param = Symbol(split(string(first(p)), "____")[end])
        mod_index = last(p)
        push!(output.args,
            Expr(:(=),
                :selected_models,
                Expr(:macrocall,
                    Symbol("@set"),
                    :(),
                    Expr(:(=), Expr(:., Expr(:ref, :selected_models, mod_index), QuoteNode(param)), Expr(:ref, :param_vector, p_index))))) #= none:1 =#
                    p_index += 1
    end
    return output
end



# """
# updateModelParametersType(tbl_params, selected_models, param_vector)
# get the new instances of the model with same parameter types as mentioned in param_vector
# """
# function updateModelParametersType(tbl_params, selected_models, param_vector)
#     updatedModels = Models.LandEcosystem[]
#     namesApproaches = nameof.(typeof.(selected_models)) # a better way to do this?
#     for (idx, modelName) ∈ enumerate(namesApproaches)
#         approachx = selected_models[idx]
#         model_obj = approachx
#         newapproachx = if modelName in tbl_params.model_approach
#             vars = propertynames(approachx)
#             newvals = Pair[]
#             for var ∈ vars
#                 pindex = findall(row -> row.name == var && row.model_approach == modelName,
#                     tbl_params)
#                 pval = getproperty(approachx, var)
#                 if !isempty(pindex)
#                     model_obj = tbl_params[pindex[1]].approach_func
#                     pval = pVector[pindex[1]]
#                 end
#                 push!(newvals, var => pval)
#             end
#             model_obj(; newvals...)
#         else
#             approachx
#         end
#         push!(updatedModels, newapproachx)
#     end
#     return updatedModels #(updatedModels...,)
# end


# """
# updateModelParametersType(tbl_params, selected_models, pVector)
# get the new instances of the model with same parameter types as mentioned in pVector
# """
# function updateModelParametersType(tbl_params, selected_models, pVector)
#     updatedModels = Models.LandEcosystem[]
#     foreach(selected_models) do approachx
#         modelName = nameof(typeof(approachx))
#         newapproachx = if modelName in tbl_params.model_approach
#             vars = getproperties(approachx)
#             newvals = Pair[]
#             for (k, var) ∈ pairs(vars)
#                 pindex = findall(row -> row.name == k && row.model_approach == modelName,
#                     tbl_params)
#                 if !isempty(pindex)
#                     #model_obj = tbl_params[pindex[1]].approach_func
#                     var = param_vector[pindex[1]]
#                 end
#                 push!(newvals, k => var)
#             end
#             constructorof(typeof(approachx))(; newvals...)
#         else
#             approachx
#         end
#         push!(updatedModels, newapproachx)
#     end
#     return updatedModels
# end

function param_indices(selected_models, tbl_params)
    r = (;)
    tempvec = Pair{Symbol,Int}[]
    for m in selected_models
          r = (;r...,indices_by_model(m, tbl_params, tempvec)...)
    end
    r
end

function indices_by_model(model, tbl_params,r)
    modelName = nameof(typeof(model))
    empty!(r)
    for var in propertynames(model)
          pindex = findfirst(row ->  row.name == var && row.model_approach == modelName,tbl_params)
          if !isnothing(pindex)
                push!(r,var=>pindex)
          end
    end
    NamedTuple((modelName=>NamedTuple(r),))
end

function updateModelParametersType(param_to_index, selected_models, pVector)
    map(selected_models) do model
          modelmap = param_to_index[nameof(typeof(model))]
          varsreplace = map(i->pVector[i],modelmap)
          ConstructionBase.setproperties(model,varsreplace)
    end
end

# @generated function
#     updateModelParametersType(param_to_index,selected_models::M,pVector) where M
#           ex = Expr(:block)
#           rets = Expr(:tuple)
#           ft = fieldtypes(M)
#           for i in eachindex(ft)
#                 modelname = QuoteNode(nameof(ft[i]))
#                 vn = Symbol("____internv_$i")
#                 push!(ex.args,:(model = selected_models[$i]))
#                 push!(ex.args,:(modelmap = param_to_index[$modelname]))
#                 push!(ex.args,:(varsreplace =
#                 map(Base.Fix1(getindex,pVector),modelmap)))
#                             push!(ex.args,:($vn = ConstructionBase.setproperties(model,varsreplace)))
#                 push!(rets.args,vn)
#           end
#           push!(ex.args,rets)
#           ex
#     end