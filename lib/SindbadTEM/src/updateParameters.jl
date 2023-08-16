
export updateModelParameters
export updateModelParametersType

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
    updateModelParameters(tbl_params, selected_models::Tuple, pVector)

update models/parameters without mutating the table of parameters

# Arguments:
- `tbl_params`: a table of SINDBAD model parameters selected for the optimization
- `selected_models`: a tuple of all models selected in the given model structure
- `pVector`: DESCRIPTION
"""
function updateModelParameters(tbl_params, selected_models::Tuple, pVector)
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
                    pval = pVector[pindex[1]]
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
    updateModelParametersType(tbl_params, selected_models::Tuple, pVector)

get the new instances of the model with same parameter types as mentioned in pVector

# Arguments:
- `tbl_params`: a table of SINDBAD model parameters selected for the optimization
- `selected_models`: a tuple of all models selected in the given model structure
- `pVector`: DESCRIPTION
"""
function updateModelParametersType(tbl_params, selected_models::Tuple, pVector)
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
                    pval = pVector[pindex[1]]
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


# """
# updateModelParametersType(tbl_params, selected_models, pVector)
# get the new instances of the model with same parameter types as mentioned in pVector
# """
# function updateModelParametersType(tbl_params, selected_models, pVector)
#     updatedModels = Models.LandEcosystem[]
#     foreach(selected_models) do approachx
#         modelName = nameof(typeof(approachx))
#         #model_obj = approachx
#         newapproachx = if modelName in tbl_params.model_approach
#             vars = getproperties(approachx)
#             newvals = Pair[]
#             for (k, var) ∈ pairs(vars)
#                 pindex = findall(row -> row.name == k && row.model_approach == modelName,
#                     tbl_params)
#                 #pval = getproperty(approachx, var)
#                 if !isempty(pindex)
#                     #model_obj = tbl_params[pindex[1]].approach_func
#                     var = pVector[pindex[1]]
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
