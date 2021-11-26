function runEcosystem(; infoExperiment = info, models = [rainSnowTair])
    o = passValsModel(models[1], infoExperiment)
    rainSnowTair!(o)
    return o
end


function passValsModel(modelApproach, info)
    nameModule = fieldtypes(methods(modelApproach).ms[1].sig)[2]
    variables = fieldnames(nameModule)
    variablesVals = []
    for var in variables
        k = 0
        for infovars in [info.forcing, info.params[Symbol(nameModule)]]
            try
                push!(variablesVals, infovars[var])
            catch
                k += 1
            end
            if k == 2
                push!(variablesVals, missing)
            end
        end
    end
    return nameModule(variablesVals...)
end

