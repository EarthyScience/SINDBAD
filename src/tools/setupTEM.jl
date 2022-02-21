
function checkModelForcingExists(info, forcingVariables)
    println("Not done")
end

function checkSelectedModels(fullModels, selModels)
    # consistency check for selected model structure
    for sm in selModels
        if sm ∉ fullModels
            println(sm, "is not a valid model from fullModels check model structure") # should throw error
            return false
        end
    end
    return true
end

function getSelectedOrderedModels(fullModels, selModels)
    if checkSelectedModels(fullModels, selModels)
        selModelsOrdered = []
        for msm in fullModels
            if msm in selModels
                push!(selModelsOrdered, msm)
            end
        end
        return selModelsOrdered
    end
end

function setupTEM(info)
    selModels = propertynames(info.modelStructure.modules)
    corePath = joinpath(pwd(), info.modelStructure.paths.coreTEM)
    info=(; info..., paths=(coreTEM = corePath));
    # (; info.paths.coreTEM..., corePath)
    # (; info..., (tem = (model = modules = selected_models)))
    # path.core = corePath
    include(corePath)
    fullModels = propertynames(getAllModels())
    selected_models = getSelectedOrderedModels(fullModels, selModels)
    
    info=(; info..., tem=(; models = selected_models));
    # info=(; info..., tem=(models = selected_models, states = ( c = names_cStates)))
    # set_tuple_fields!(info, "info.tem.models", selected_models)

    # for feildname in split("info.tem.models")
    #     if field != "info"
    #         if ∉ info
    #     info = (; info..., fieldname)
    # end

    # info.tem.models = selected_models
    # info.tem.variables.states.c =  names_cStates
    # info.tem.variables.states.w = names_wStates
    return info
end



# runmodel

# post process
