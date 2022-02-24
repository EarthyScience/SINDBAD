using Sinbad.Models
export setupTEM!

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

function getSelectedApproaches(info, selModelsOrdered)
    sel_appr_forward = []
    sel_appr_spinup = []
    println(selModelsOrdered)
    for sm in selModelsOrdered
        modInfo = getfield(info.modelStructure.models, sm)
        modAppr = modInfo.apprName
        sel_approach = String(sm) * "_" * modAppr
        sel_approach_func = getfield(Sinbad.Models, Symbol(sel_approach))()
        push!(sel_appr_forward, sel_approach_func)
        if modInfo.use4spinup == true
            push!(sel_appr_spinup, sel_approach_func)
        end
    end
    info=(; info..., tem=(; models = (; forward = sel_appr_forward, spinup = sel_appr_spinup)));
    return info
end

function setupTEM!(info)
    selModels = propertynames(info.modelStructure.models)
    # corePath = joinpath(pwd(), info.modelStructure.paths.coreTEM)
    # info=(; info..., paths=(coreTEM = corePath));
    # include(corePath)
    fullModels = propertynames(getEcoProcess())
    selected_models = getSelectedOrderedModels(fullModels, selModels)
    info = getSelectedApproaches(info, selected_models)
    return info
end
