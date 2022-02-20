
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

function setupTEM!(info)
    selModels = propertynames(info.modelStructure.modules)
    corePath = joinpath(pwd(), info.modelStructure.paths.coreTEM)
    (; info.paths.coreTEM..., corePath)
    (; info..., (tem = (model = modules = selected_models)))
    # path.core = corePath
    include(corePath)
    fullModels = propertynames(getAllModels())
    selected_models = getSelectedOrderedModels(fullModels, selModels)
    info.tem.model.modules = selected_models
    return info
end



# runmodel

# post process
