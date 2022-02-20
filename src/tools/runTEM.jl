function runCoreTEM(info, forcing, out)
    # m0 = getStates()
    # m1 = rainSnow()
    # m2 = snowMelt()
    # m3 = evapSoil()
    # m4 = transpiration()
    # m5 = updateState()
    # models = (m0, m1, m2, m3, m4, m5)
    models = info.tem.models # put the selected models here
    outTable = evolveEcosystem(forcing, models, timesteps) # evolve is intransitive, may be use update?
    return outTable
end

function runSpinupTEM(info, forcing)
### handle spinup things here
### runs
end

function runTEM(info, forcing, optimize=false, observation=nothing)
    # runSpinupTEM
    # runCoreTEM
end




