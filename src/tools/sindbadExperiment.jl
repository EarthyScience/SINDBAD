using Revise
using Sinbad
using Test
using JSON


expFile = "sandbox/test_json/settings_minimal/experiment.json"

jsonFile = String(read(expFile))    
parseFile = JSON.parse(jsonFile)
files = []
info = Dict()
for (k, v) in parseFile["configFiles"]
    push!(files, v)
    info[k] = rmComments(; inputDict = JSON.parse(String(read(v))))
end

info2 = typenarrow!(info);
selModels=propertynames(info2.modelStructure.modules)
# conf = getConfiguration()

include(joinpath(pwd(), info2.modelStructure.paths.coreTEM))
fullModels = propertynames(getOrderedModels())

function checkModel(fullModels, selModels)
    # consistency check for selected model structure
    for sm in selModels
        if sm ∉ fullModels
            println(sm, "is not a valid model from fullModels check model structure") # should throw error
            return false
        end
    end
    return true
end

function selectModelsOrdered(fullModels, selModels)
    if checkModel(fullModels, selModels)
        selModelsOrdered = []
        for msm in fullModels
            if msm in selModels
                push!(selModelsOrdered, msm)
            end
        end
        return selModelsOrdered
    end
end

selectModelsOrdered(fullModels, selModels)



# runmodel

# post process
